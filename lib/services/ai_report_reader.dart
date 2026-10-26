import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../config/ai_config.dart';
import '../models/lab_marker.dart';
import '../models/medical_report.dart';
import 'app_log.dart';

/// Raised when the fallback cannot produce a usable reading.
class AiReadException implements Exception {
  AiReadException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Last-resort reader for lab reports the built-in parser did not recognise.
///
/// The model is asked for structure only — marker names, numbers, units,
/// ranges. Everything it returns is range-checked and clamped before it
/// reaches the rest of the app, because a confidently wrong number is far
/// more dangerous in a medical report than a missing one.
class AiReportReader {
  AiReportReader({http.Client? client}) : _client = client ?? http.Client();

  static const _uuid = Uuid();
  final http.Client _client;

  /// Values outside this band are rejected outright; no lab marker in the
  /// catalogue comes close to either end.
  static const double _minPlausible = -1e6;
  static const double _maxPlausible = 1e7;

  static const int _maxMarkers = 120;
  static const int _maxTextLength = 24000;

  bool get isAvailable => AiConfig.isConfigured;

  /// Sends [text] for reading and returns a report built from the response.
  ///
  /// [text] should already have been through [redact].
  Future<MedicalReport> read({
    required String fileName,
    required String text,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    if (!AiConfig.isConfigured) {
      throw AiReadException('AI reading is not configured for this build.');
    }

    final trimmed = text.length > _maxTextLength
        ? text.substring(0, _maxTextLength)
        : text;

    final response = await _client
        .post(
          AiConfig.endpoint,
          headers: {
            'Content-Type': 'application/json',
            if (AiConfig.usesDirectKey)
              'Authorization': 'Bearer ${AiConfig.openAiKey}',
          },
          body: jsonEncode({
            'model': AiConfig.model,
            'temperature': 0,
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {'role': 'user', 'content': trimmed},
            ],
          }),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      AppLog.ai.response(response.statusCode, AiConfig.endpoint);
      throw AiReadException('The reading service returned an error.');
    }

    final content = _contentOf(response.bodyBytes);
    final parsed = _decode(content);
    return _toReport(fileName: fileName, data: parsed, excerpt: trimmed);
  }

  /// Best-effort removal of direct identifiers before the text leaves the
  /// device. Formats we have never seen may still carry a name through, so
  /// this reduces exposure rather than eliminating it — the consent prompt
  /// says as much.
  static String redact(
    String text, {
    String? patientName,
    String? phone,
    String? email,
    String? address,
  }) {
    var out = text;

    for (final value in [patientName, phone, email, address]) {
      final needle = value?.trim();
      if (needle == null || needle.length < 4) continue;
      out = out.replaceAll(needle, '[redacted]');
    }

    out = out.replaceAll(
      RegExp(r'[\w.+-]+@[\w-]+\.[\w.]{2,}'),
      '[redacted]',
    );
    out = out.replaceAll(
      RegExp(r'\+?\d[\d\s().-]{7,}\d'),
      '[redacted]',
    );

    return out;
  }

  String _contentOf(List<int> bodyBytes) {
    final body = jsonDecode(utf8.decode(bodyBytes));
    if (body is! Map) throw AiReadException('Unexpected response shape.');

    // A proxy may hand back the parsed object directly rather than the
    // OpenAI envelope.
    if (body['markers'] != null) return jsonEncode(body);

    final choices = body['choices'];
    if (choices is! List || choices.isEmpty) {
      throw AiReadException('The reading service returned nothing.');
    }
    final message = (choices.first as Map)['message'];
    final content = (message as Map)['content'];
    if (content is! String || content.trim().isEmpty) {
      throw AiReadException('The reading service returned nothing.');
    }
    return content;
  }

  Map<String, dynamic> _decode(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // falls through
    }
    throw AiReadException('Could not understand the reading service reply.');
  }

  MedicalReport _toReport({
    required String fileName,
    required Map<String, dynamic> data,
    required String excerpt,
  }) {
    final markers = _markersFrom(data['markers']);
    if (markers.isEmpty) {
      throw AiReadException('No lab values could be read from this file.');
    }

    final summary = _text(data['summary'], 600) ?? '';

    return MedicalReport(
      id: _uuid.v4(),
      fileName: fileName,
      uploadedAt: DateTime.now(),
      summary: summary,
      whatToDo: _suggestions(data['suggestions']),
      markers: markers,
      readByAi: true,
      examTitle: _text(data['examTitle'], 120),
      clinicName: _text(data['clinicName'], 120),
      sampleDate: _text(data['sampleDate'], 40),
      doctorName: _text(data['doctorName'], 80),
      method: _text(data['method'], 120),
      rawExcerpt: excerpt.length > 900
          ? '${excerpt.substring(0, 900).trim()}…'
          : excerpt,
    );
  }

  List<LabMarker> _markersFrom(Object? raw) {
    if (raw is! List) return const [];
    final seen = <String>{};
    final markers = <LabMarker>[];

    for (final entry in raw) {
      if (markers.length >= _maxMarkers) break;
      if (entry is! Map) continue;

      final name = _text(entry['name'], 80);
      if (name == null) continue;

      final value = _number(entry['value']);
      final resultText = _text(entry['resultText'], 60);
      if (value == null && resultText == null) continue;

      var id = _slug(name);
      if (id.isEmpty) continue;
      // Stable ids keep History's test-to-test comparison working.
      var suffix = 2;
      while (!seen.add(id)) {
        id = '${_slug(name)}_$suffix';
        suffix++;
      }

      markers.add(
        LabMarker(
          id: id,
          name: name,
          unit: _text(entry['unit'], 24) ?? '',
          status: _status(entry['status']),
          value: value,
          resultText: resultText,
          referenceRange: _text(entry['referenceRange'], 60),
          information: _text(entry['information'], 400),
          recommendation: _text(entry['recommendation'], 400),
        ),
      );
    }

    return markers;
  }

  List<String> _suggestions(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => _text(e, 240))
        .whereType<String>()
        .take(6)
        .toList();
  }

  static MarkerStatus _status(Object? raw) {
    final value = raw?.toString().trim().toLowerCase();
    return switch (value) {
      'normal' || 'in range' || 'ok' => MarkerStatus.normal,
      'low' || 'below' => MarkerStatus.low,
      'high' || 'above' => MarkerStatus.high,
      _ => MarkerStatus.unknown,
    };
  }

  /// Rejects anything non-finite or physically implausible rather than
  /// passing a hallucinated number into the health screens.
  static double? _number(Object? raw) {
    final value = switch (raw) {
      num n => n.toDouble(),
      String s => double.tryParse(s.replaceAll(',', '.').trim()),
      _ => null,
    };
    if (value == null || !value.isFinite) return null;
    if (value < _minPlausible || value > _maxPlausible) return null;
    return value;
  }

  static String? _text(Object? raw, int maxLength) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return null;
    return value.length > maxLength ? value.substring(0, maxLength) : value;
  }

  static String _slug(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? '' : 'ai_$slug';
  }

  static const String _systemPrompt = '''
You read laboratory test reports and return structured data.

Return a single JSON object with these keys:
  examTitle, clinicName, sampleDate, doctorName, method  (strings or null)
  summary       - two plain sentences a non-doctor can follow
  suggestions   - up to 4 short, general wellbeing actions
  markers       - array of the measured values

Each marker object:
  name            - the test name, in the language of the report
  value           - the measured number, or null if the result is a word
  resultText      - the result word (e.g. "Negative"), or null if numeric
  unit            - measurement unit, or ""
  referenceRange  - the range printed on the report, or null
  status          - "normal", "low", "high", or "unknown"
  information     - one sentence on what this marker means
  recommendation  - one sentence of general guidance

Rules you must follow:
- Copy numbers exactly as printed. Never estimate, convert, or infer a value.
- If a value is unclear or missing, omit that marker entirely.
- Set status only from the reference range printed on the report. If no range
  is printed, use "unknown".
- Never diagnose, never name a medication, never suggest a dose.
- Return only the JSON object, with no commentary.
''';
}
