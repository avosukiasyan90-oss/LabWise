import 'package:uuid/uuid.dart';

import '../models/lab_marker.dart';
import '../models/medical_report.dart';
import 'lab_knowledge.dart';
import 'helicobacter_catalog.dart';
import 'urinalysis_catalog.dart';
import 'urogenital_catalog.dart';

class MedicalAnalyzer {
  static const _uuid = Uuid();
  static final _urineParser = UrinalysisParser();
  static final _urogenitalParser = UrogenitalParser();
  static final _helicobacterParser = HelicobacterParser();

  /// Supports CBC codes like NEUT%, LYMPH#, RDW-SD, P-LCR, and packed forms like 1ESR.
  static final RegExp _assayResultPattern = RegExp(
    r'(\d{1,3}(?:[.,]\d{1,4})?)\s*([A-Z][A-Z0-9-]{1,12}[%#]?)(?![A-Za-z0-9%#])',
  );

  MedicalReport analyze({
    required String fileName,
    required String text,
  }) {
    final normalized = _normalize(text);
    final meta = _extractMeta(normalized);
    final markers = _extractAllMarkers(normalized);

    final abnormal = markers.where((m) => m.isAbnormal).toList();
    final summary = _buildSummary(markers, abnormal, meta);
    final suggestions = _buildSuggestions(markers, abnormal);
    final excerpt = normalized.length > 900
        ? '${normalized.substring(0, 900).trim()}…'
        : normalized;

    final contact = _extractContact(normalized);

    return MedicalReport(
      id: _uuid.v4(),
      fileName: fileName,
      uploadedAt: DateTime.now(),
      summary: summary,
      whatToDo: suggestions,
      markers: markers,
      clinicName: contact.clinic,
      patientAddress: contact.address,
      patientPhone: contact.phone,
      patientEmail: contact.email,
      licenseNumber: contact.license,
      patientName: meta.patientName,
      examTitle: meta.examTitle,
      reportNumber: meta.reportNumber,
      sampleDate: meta.sampleDate,
      doctorName: meta.doctorName,
      method: meta.method,
      rawExcerpt: excerpt,
    );
  }

  MedicalReport demoReport() {
    const sample = '''
EXAMINATION REPORT № DEMO-001
Patient SUKIASYAN AVETIK
BIOCHEMICAL EXAMINATION
Registration date 15/02/2025 11:08:46
Manipulation date 15/02/2025 11:13:34
Glucose
mmol/L 4,11 - 5,89 5.80 GLUC
Cholesterol
mmol/L No risk: Moderate risk: High risk:
<5.2 5.2 - 7.8 >7.8 6.36 CHOL
Triglycerides
mmol/L < 2,26 1.32 TRIGL
High-density lipoprotein
mmol/L >1.45 0.9 - 1.45 <0.9 1.33 HDL-C
Low-density lipoprotein
mmol/L <2.6 <3.5 >4.1 4.44 LDL-C
Method: photometric
Doctor Shahinyan N.
''';
    return analyze(fileName: 'demo_lab_panel.pdf', text: sample);
  }

  List<LabMarker> _extractAllMarkers(String text) {
    final markers = <LabMarker>[];
    final seenIds = <String>{};
    final isUrine = _urineParser.isUrinalysis(text);
    final isUrogenital = _urogenitalParser.isUrogenitalReport(text);
    final isHelicobacter = _helicobacterParser.isHelicobacterTest(text);
    final workingText = isUrogenital
        ? _urogenitalParser.normalizeScientificNotation(text)
        : text;

    // 1) Urinalysis strip panels (qualitative + SG/pH).
    for (final marker in _urineParser.parse(workingText)) {
      if (seenIds.contains(marker.id)) continue;
      markers.add(marker);
      seenIds.add(marker.id);
    }

    // 1b) Urogenital smear + Androflor PCR panels (RU/EN).
    for (final marker in _urogenitalParser.parse(workingText)) {
      if (seenIds.contains(marker.id)) continue;
      markers.add(marker);
      seenIds.add(marker.id);
    }

    // 1c) Helicobacter urea breath tests (tick next to Negative/Positive).
    for (final marker in _helicobacterParser.parse(workingText)) {
      if (seenIds.contains(marker.id)) continue;
      markers.add(marker);
      seenIds.add(marker.id);
    }

    // 2) Read every assay-code result in the whole document.
    if (!isUrine && !isUrogenital && !isHelicobacter) {
      for (final match in _assayResultPattern.allMatches(workingText)) {
        final value = _toDouble(match.group(1)!);
        final code = match.group(2)!;
        if (value == null) continue;
        if (_looksLikeDateOrTimeNoise(workingText, match.start, value)) {
          continue;
        }
        if (_isIgnoredAssayCode(code)) continue;

        final knowledge = LabCatalog.byAssayCode(code);
        final nearby =
            _window(workingText, match.start, before: 160, after: 40);
        // Unknown codes need nearby lab units so we don't pick random text.
        if (knowledge == null && !_hasLabUnit(nearby)) continue;

        final id = knowledge?.id ?? 'code_${code.toLowerCase()}';
        if (seenIds.contains(id)) continue;

        final unitSystem = _detectUnit(nearby, workingText);
        final marker = _buildMarker(
          knowledge: knowledge,
          fallbackName: _guessNameNear(nearby) ?? code,
          value: value,
          unitSystem: unitSystem,
          assayCode: code,
          nearbyText: nearby,
        );
        markers.add(marker);
        seenIds.add(id);
      }

      // 3) Catch known blood markers by name if assay code was missing.
      for (final knowledge in LabCatalog.all) {
        if (seenIds.contains(knowledge.id)) continue;
        for (final pattern in knowledge.namePatterns) {
          final match = pattern.firstMatch(workingText);
          if (match == null) continue;
          final nearby =
              _window(workingText, match.start, before: 20, after: 180);
          // Skip qualitative urine-style "negative" hits for blood markers.
          if (RegExp(r'\bnegative\b', caseSensitive: false).hasMatch(nearby) &&
              !_assayResultPattern.hasMatch(nearby)) {
            continue;
          }
          final value = _extractLooseResult(nearby);
          if (value == null) continue;
          final unitSystem = _detectUnit(nearby, workingText);
          markers.add(
            _buildMarker(
              knowledge: knowledge,
              fallbackName: knowledge.name,
              value: value,
              unitSystem: unitSystem,
              assayCode: knowledge.assayCodes.isNotEmpty
                  ? knowledge.assayCodes.first
                  : null,
              nearbyText: nearby,
            ),
          );
          seenIds.add(knowledge.id);
          break;
        }
      }
    }

    int rank(LabMarker m) => m.isAbnormal ? 0 : 1;
    markers.sort((a, b) {
      final cmp = rank(a).compareTo(rank(b));
      if (cmp != 0) return cmp;
      return a.name.compareTo(b.name);
    });
    return markers;
  }

  LabMarker _buildMarker({
    required LabKnowledge? knowledge,
    required String fallbackName,
    required double value,
    required _UnitSystem unitSystem,
    required String? assayCode,
    required String nearbyText,
  }) {
    final ranges = _rangesFor(knowledge, unitSystem, nearbyText);
    final status = knowledge == null
        ? MarkerStatus.unknown
        : _statusFor(value, ranges.low, ranges.high);

    final parsedRef = _extractReference(nearbyText);
    final information = knowledge?.information ??
        'This value was read from your uploaded report'
            '${assayCode != null ? ' (code $assayCode)' : ''}.';
    final description = knowledge?.description ??
        'No built-in medical profile for this marker yet. Compare it with the lab reference range and ask your clinician if unsure.';
    final recommendation = knowledge?.suggestionFor(status) ??
        'Bring this result to your clinician for interpretation in your full health context.';

    return LabMarker(
      id: knowledge?.id ?? 'unknown_${(assayCode ?? fallbackName).toLowerCase()}',
      name: knowledge?.name ?? fallbackName,
      value: value,
      unit: ranges.unit,
      status: status,
      referenceRange: parsedRef ?? ranges.referenceRange,
      information: information,
      description: description,
      recommendation: recommendation,
      assayCode: assayCode,
    );
  }

  LabRanges _rangesFor(
    LabKnowledge? knowledge,
    _UnitSystem unitSystem,
    String nearbyText,
  ) {
    if (knowledge == null) {
      final unit = _unitLabel(nearbyText) ?? '';
      return LabRanges(
        low: double.negativeInfinity,
        high: double.infinity,
        referenceRange: _extractReference(nearbyText) ?? 'See report',
        unit: unit,
      );
    }
    if (unitSystem == _UnitSystem.mmolL && knowledge.mmolL != null) {
      return knowledge.mmolL!;
    }
    return knowledge.mgDl;
  }

  /// Pulls the contact block printed on lab reports. In the formats we support
  /// (Armenian and Russian) these values describe the patient, not the clinic.
  _ContactInfo _extractContact(String text) {
    final lines = text.split('\n');

    String? valueFor(RegExp label, {int continuationLines = 0}) {
      for (var i = 0; i < lines.length; i++) {
        final match = label.firstMatch(lines[i]);
        if (match == null) continue;

        final parts = <String>[lines[i].substring(match.end).trim()];
        for (var j = 1; j <= continuationLines; j++) {
          final next = i + j;
          if (next >= lines.length) break;
          final candidate = lines[next].trim();
          // A new label always carries a "/" separator or a trailing colon.
          if (candidate.isEmpty ||
              candidate.contains('/') ||
              candidate.contains(':')) {
            break;
          }
          parts.add(candidate);
        }

        final value = parts.where((p) => p.isNotEmpty).join(' ').trim();
        if (value.isNotEmpty) return value;
      }
      return null;
    }

    return _ContactInfo(
      address: valueFor(
            RegExp(r'(?:Հասցե\s*/\s*)?Address\b[:\s]*', caseSensitive: false),
            continuationLines: 2,
          ) ??
          // Dart's \b only recognises ASCII word characters, so Cyrillic
          // labels are matched without it.
          valueFor(RegExp(r'Адрес[:\s]*', caseSensitive: false)),
      phone: valueFor(
            RegExp(r'(?:Հեռ\.?\s*/\s*)?Tel\.?\b[:\s]*', caseSensitive: false),
          ) ??
          valueFor(
            RegExp(r'Контакт\.?\s*данные[:\s]*', caseSensitive: false),
          ) ??
          RegExp(r'(\+\d{8,15})').firstMatch(text)?.group(1),
      email: valueFor(
        RegExp(r'E-?mail\b[:\s]*', caseSensitive: false),
      ),
      license: valueFor(
        RegExp(r'(?:ԼԻՑԵՆԶԻԱ\s*/\s*)?LICENSE\b[:\s]*', caseSensitive: false),
      ),
      clinic: valueFor(
            RegExp(
              r'կազմակերպության\s*անվանումը[՝:\s]*',
              caseSensitive: false,
            ),
          ) ??
          valueFor(
            RegExp(r'(?:Clinic|Laboratory|Лаборатория)[:\s]+',
                caseSensitive: false),
          ),
    );
  }

  String? _normalizeMethod(String? value) {
    if (value == null) return null;
    final collapsed = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.isEmpty) return null;
    // Rejoin an isotope number with its element symbol.
    return collapsed
        .replaceAllMapped(
          RegExp(r'(\d+)\s+([CN])(?![A-Za-z])'),
          (m) => '${m[1]}${m[2]}',
        )
        .trim();
  }

  _DocumentMeta _extractMeta(String text) {
    String? firstGroup(RegExp pattern) =>
        pattern.firstMatch(text)?.group(1)?.trim();

    final reportNumber = firstGroup(
          RegExp(r'(?:EXAMINATION REPORT|REPORT)\s*№?\s*([A-Z0-9-]+)',
              caseSensitive: false),
        ) ??
        firstGroup(
          RegExp(
            r'Идентификационный\s*N\s*([0-9A-Z-]+)',
            caseSensitive: false,
          ),
        ) ??
        firstGroup(RegExp(r'№\s*([A-Z0-9-]+)'));

    final patientName = firstGroup(
          RegExp(r'Patient\s+([A-Z][A-Z\s]{2,60})'),
        ) ??
        // Armenian labels put the name on the following line.
        firstGroup(
          RegExp(
            r'Հաճախորդի\s*ԱԱՀ[՝:]?\s*([^\n]{3,80})',
            caseSensitive: false,
          ),
        ) ??
        firstGroup(
          RegExp(r'Հետազոտվող[`՝:]?\s*([^\n]{3,80})', caseSensitive: false),
        ) ??
        firstGroup(
          RegExp(
            r'Ф\.?\s*И\.?\s*О\.?\s*([^\n]{3,80})',
            caseSensitive: false,
          ),
        );

    final examTitle = firstGroup(
          RegExp(
            r'((?:BIOCHEMICAL|HEMATOLOGY|GENERAL|CLINICAL)[^\n]{0,40}EXAMINATION)',
            caseSensitive: false,
          ),
        ) ??
        firstGroup(
          RegExp(
            r'(COMPLETE BLOOD COUNT[^\n]{0,20})',
            caseSensitive: false,
          ),
        ) ??
        firstGroup(
          RegExp(
            r'(URINALYSIS[^\n]{0,40})',
            caseSensitive: false,
          ),
        ) ??
        firstGroup(
          RegExp(
            r'(АНДРОФЛОР[^\n]{0,40}|Androflor[^\n]{0,40})',
            caseSensitive: false,
          ),
        ) ??
        firstGroup(
          RegExp(
            r'(РЕЗУЛЬТАТЫ МИКРОСКОПИЧЕСКИХ[^\n]{0,60})',
            caseSensitive: false,
          ),
        ) ??
        firstGroup(
          RegExp(r'(ՀԵԼԻԿ\s*ԹԵՍՏ|Հելիկ\s*[Թթ]եստ)', caseSensitive: false),
        );

    final sampleDate = firstGroup(
          RegExp(
            r'(?:Manipulation date|Registration date)[^\d]*(\d{1,2}/\d{1,2}/\d{4}(?:\s+\d{2}:\d{2}(?::\d{2})?)?)',
            caseSensitive: false,
          ),
        ) ??
        firstGroup(
          RegExp(
            r'Дата взятия[^\d]*(\d{1,2}[./]\d{1,2}[./]\d{4}(?:\s+\d{1,2}:\d{2})?)',
            caseSensitive: false,
          ),
        ) ??
        firstGroup(
          RegExp(
            r'Հետազոտության\s*ամսաթիվ[՝:\s]*(\d{1,2}[./]\d{1,2}[./]\d{4}(?:\s+\d{1,2}:\d{2})?)',
            caseSensitive: false,
          ),
        );

    final doctorName = firstGroup(
          RegExp(r'Doctor\s*([A-Za-z\.][A-Za-z\. ]{2,40})',
              caseSensitive: false),
        ) ??
        firstGroup(
          RegExp(r'Ուղղորդող\s*բժիշկ[՝:\s]*([^\n]{2,60})',
              caseSensitive: false),
        );

    // The isotope label wraps onto its own lines ("Heliforce Urea /\n13\nC").
    final method = _normalizeMethod(
          firstGroup(
            RegExp(
              r'Հելիկ\s*թեստի\s*անվանում[՝:\s]+([\s\S]{2,60}?)\s*(?=Եզրակացություն|\n\s*\n)',
              caseSensitive: false,
            ),
          ),
        ) ??
        firstGroup(
          RegExp(r'Method[:\s-]+([^\n]{2,80})', caseSensitive: false),
        ) ??
        firstGroup(
          RegExp(r'Метод[:\s-]+([^\n]{2,80})', caseSensitive: false),
        );

    return _DocumentMeta(
      reportNumber: reportNumber,
      patientName: patientName,
      examTitle: examTitle,
      sampleDate: sampleDate,
      doctorName: doctorName,
      method: method,
    );
  }

  String _buildSummary(
    List<LabMarker> markers,
    List<LabMarker> abnormal,
    _DocumentMeta meta,
  ) {
    final exam = meta.examTitle ?? 'lab report';
    if (markers.isEmpty) {
      return 'We read your document but could not extract structured test points. '
          'Please keep the original file for your clinician.';
    }
    if (abnormal.isEmpty) {
      return 'Fully reviewed this $exam and found ${markers.length} test points. '
          'All recognized values look within typical ranges.';
    }
    final names = abnormal.map((m) => m.name).join(', ');
    return 'Fully reviewed this $exam and found ${markers.length} test points. '
        '${abnormal.length} need attention: $names.';
  }

  List<String> _buildSuggestions(
    List<LabMarker> markers,
    List<LabMarker> abnormal,
  ) {
    final suggestions = <String>[
      'This guidance is educational only — confirm decisions with a licensed clinician.',
    ];

    if (markers.isEmpty) {
      suggestions.add('Share the original PDF/Word report with your doctor.');
      return suggestions;
    }

    if (abnormal.isEmpty) {
      suggestions.add('Keep your current healthy routines and routine checkups.');
      return suggestions;
    }

    for (final marker in abnormal) {
      if (marker.recommendation != null) {
        suggestions.add('${marker.name}: ${marker.recommendation}');
      }
    }

    if (abnormal.any((m) => m.id == 'ldl' || m.id == 'cholesterol')) {
      suggestions.add(
        'Heart-focused focus: more vegetables/fiber, less fried food, and regular walking.',
      );
    }
    if (abnormal.any((m) => m.id == 'hdl')) {
      suggestions.add(
        'Activity helps HDL: aim for brisk walking most days of the week.',
      );
    }
    if (abnormal.any((m) => m.id == 'glucose' || m.id == 'hba1c')) {
      suggestions.add(
        'After meals, a 10–15 minute walk can help with glucose control.',
      );
    }

    return suggestions.toSet().toList();
  }

  double? _extractLooseResult(String window) {
    for (final match in _assayResultPattern.allMatches(window)) {
      return _toDouble(match.group(1)!);
    }

    var cleaned = window;
    cleaned = cleaned.replaceAll(
      RegExp(r'(?:no|low|moderate|high)\s*risk\s*:[^\n]*', caseSensitive: false),
      ' ',
    );
    cleaned = cleaned.replaceAll(RegExp(r'[<>]=?\s*\d{1,3}(?:[.,]\d{1,3})?'), ' ');
    cleaned = cleaned.replaceAll(
      RegExp(r'\d{1,3}(?:[.,]\d{1,3})?\s*[-–—]\s*\d{1,3}(?:[.,]\d{1,3})?'),
      ' ',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\b\d{1,2}/\d{1,2}/\d{2,4}\b'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\b\d{1,2}:\d{2}(?::\d{2})?\b'), ' ');

    final numbers = RegExp(r'(\d{1,3}(?:[.,]\d{1,3})?)')
        .allMatches(cleaned)
        .map((m) => _toDouble(m.group(1)!))
        .whereType<double>()
        .where((n) => n < 2000)
        .toList();
    if (numbers.isEmpty) return null;
    return numbers.last;
  }

  String? _extractReference(String nearby) {
    final range = RegExp(
      r'(\d{1,3}(?:[.,]\d{1,3})?\s*[-–—]\s*\d{1,3}(?:[.,]\d{1,3})?)',
    ).firstMatch(nearby);
    if (range != null) return range.group(1)!.replaceAll(',', '.');

    final less = RegExp(
      r'<\s*(\d{1,3}(?:[.,]\d{1,3})?)',
    ).firstMatch(nearby);
    if (less != null) return '< ${less.group(1)!.replaceAll(',', '.')}';

    final greater = RegExp(
      r'>\s*(\d{1,3}(?:[.,]\d{1,3})?)',
    ).firstMatch(nearby);
    if (greater != null) return '> ${greater.group(1)!.replaceAll(',', '.')}';
    return null;
  }

  String? _guessNameNear(String nearby) {
    final english = RegExp(
      r'((?:High|Low)[- ]density lipoprotein|Triglycerides?|Cholesterol|Glucose|Hemoglobin|Creatinine|Vitamin D|TSH|HbA1c)',
      caseSensitive: false,
    ).firstMatch(nearby);
    if (english != null) return english.group(1);
    return null;
  }

  bool _looksLikeDateOrTimeNoise(String text, int index, double value) {
    if (value >= 1900 && value <= 2100) return true;
    final nearby = _window(text, index, before: 12, after: 12);
    if (RegExp(r'\d{1,2}/\d{1,2}/\d{2,4}').hasMatch(nearby)) return true;
    if (RegExp(r'\d{1,2}:\d{2}').hasMatch(nearby)) return true;
    return false;
  }

  bool _isIgnoredAssayCode(String code) {
    const ignored = {
      'JAPAN',
      'FRANCE',
      'CHINA',
      'RISK',
      'HIGH',
      'LOW',
      'MALE',
      'FEMALE',
      'PAGE',
      'TEST',
      'UNIT',
      'NAME',
      'DATE',
      'DEMO',
      'LICENSE',
      'XX',
      'HORIBA',
      'YUMIZEN',
    };
    return ignored.contains(code.toUpperCase());
  }

  bool _hasLabUnit(String nearby) {
    return RegExp(
      r'(mmol(?:/L)?|mg(?:\s*/?\s*dL)?|g/dL|U/L|IU/L|mIU/L|ng/mL|pg(?:/mL)?|µmol/L|umol/L|10\^?\s*9|10\^?\s*12|f\s*L|mm/h|%)',
      caseSensitive: false,
    ).hasMatch(nearby);
  }

  _UnitSystem _detectUnit(String nearby, String fullText) {
    final slice = nearby.toLowerCase();
    if (slice.contains('mmol')) return _UnitSystem.mmolL;
    if (slice.contains('mg/dl') || slice.contains('mg / dl')) {
      return _UnitSystem.mgDl;
    }
    if (RegExp(r'\bmmol\b', caseSensitive: false).hasMatch(fullText) &&
        !RegExp(r'\bmg\s*/?\s*dl\b', caseSensitive: false).hasMatch(fullText)) {
      return _UnitSystem.mmolL;
    }
    return _UnitSystem.mgDl;
  }

  String? _unitLabel(String nearby) {
    final match = RegExp(
      r'\b(mmol/L|mg/dL|g/dL|U/L|mIU/L|ng/mL|pg/mL|µmol/L|ug/dL|µg/dL)\b',
      caseSensitive: false,
    ).firstMatch(nearby);
    return match?.group(1);
  }

  String _window(String text, int index, {int before = 80, int after = 80}) {
    final start = (index - before).clamp(0, text.length);
    final end = (index + after).clamp(0, text.length);
    return text.substring(start, end);
  }

  String _normalize(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  double? _toDouble(String raw) => double.tryParse(raw.replaceAll(',', '.'));

  MarkerStatus _statusFor(double value, double low, double high) {
    if (value < low) return MarkerStatus.low;
    if (value > high) return MarkerStatus.high;
    return MarkerStatus.normal;
  }
}

enum _UnitSystem { mgDl, mmolL }

class _DocumentMeta {
  const _DocumentMeta({
    this.reportNumber,
    this.patientName,
    this.examTitle,
    this.sampleDate,
    this.doctorName,
    this.method,
  });

  final String? reportNumber;
  final String? patientName;
  final String? examTitle;
  final String? sampleDate;
  final String? doctorName;
  final String? method;
}

class _ContactInfo {
  const _ContactInfo({
    this.address,
    this.phone,
    this.email,
    this.license,
    this.clinic,
  });

  final String? address;
  final String? phone;
  final String? email;
  final String? license;
  final String? clinic;
}
