import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileExtractor {
  Future<String> extractText({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return _extractPdf(bytes);
    }
    if (lower.endsWith('.docx')) {
      return _extractDocx(bytes);
    }
    if (lower.endsWith('.doc')) {
      throw UnsupportedError(
        'Old .doc files are not supported. Please save as .docx or PDF.',
      );
    }
    throw UnsupportedError('Please upload a PDF or Word (.docx) file.');
  }

  String _extractPdf(Uint8List bytes) {
    final document = PdfDocument(inputBytes: bytes);
    try {
      final extractor = PdfTextExtractor(document);
      final fromLines = _extractPdfByLines(extractor);
      final plain = extractor.extractText().trim();

      // Prefer layout-aware lines when they capture more structured content.
      final candidates = <String>[
        if (fromLines.trim().isNotEmpty) fromLines.trim(),
        if (plain.isNotEmpty) plain,
      ];
      if (candidates.isEmpty) {
        throw StateError(
          'No readable text found in this PDF. It may be a scanned image.',
        );
      }

      candidates.sort((a, b) {
        final scoreCmp = _structureScore(b).compareTo(_structureScore(a));
        if (scoreCmp != 0) return scoreCmp;
        return b.length.compareTo(a.length);
      });
      return _normalize(candidates.first);
    } finally {
      document.dispose();
    }
  }

  String _extractPdfByLines(PdfTextExtractor extractor) {
    final buffer = StringBuffer();
    try {
      final lines = extractor.extractTextLines();
      String? previous;
      for (final line in lines) {
        final text = line.text.trim();
        if (text.isEmpty) continue;
        if (previous != null && previous == text) continue;
        buffer.writeln(text);
        previous = text;
      }
    } catch (_) {
      // Some PDFs fail line extraction; caller falls back to plain text.
    }
    return buffer.toString();
  }

  int _structureScore(String text) {
    var score = 0;
    if (RegExp(r'\bmmol\b', caseSensitive: false).hasMatch(text)) score += 3;
    if (RegExp(r'\bmg\s*/?\s*dl\b', caseSensitive: false).hasMatch(text)) {
      score += 2;
    }
    if (RegExp(r'\b(?:GLUC|CHOL|TRIGL|HDL-C|LDL-C|HBA1C|TSH|ALT|AST)\b')
        .hasMatch(text)) {
      score += 8;
    }
    if (RegExp(r'Reference|Results|EXAMINATION', caseSensitive: false)
        .hasMatch(text)) {
      score += 2;
    }
    score += RegExp(r'\n').allMatches(text).length;
    return score;
  }

  String _extractDocx(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final documentXml = archive.findFile('word/document.xml');
    if (documentXml == null) {
      throw StateError('Could not read this Word document.');
    }

    final xml = utf8.decode(documentXml.content as List<int>);
    final buffer = StringBuffer();
    final tag = RegExp(r'<w:t[^>]*>(.*?)</w:t>', dotAll: true);
    final breaks = RegExp(r'</w:p>|<w:br[^/]*/>');

    var cursor = 0;
    final tokens = <_Token>[];
    for (final match in tag.allMatches(xml)) {
      tokens.add(_Token(match.start, _unescapeXml(match.group(1) ?? '')));
    }
    for (final match in breaks.allMatches(xml)) {
      tokens.add(_Token(match.start, '\n'));
    }
    tokens.sort((a, b) => a.index.compareTo(b.index));

    for (final token in tokens) {
      if (token.index < cursor) continue;
      buffer.write(token.value);
      cursor = token.index;
    }

    final text = _normalize(buffer.toString());
    if (text.isEmpty) {
      throw StateError('No readable text found in this Word file.');
    }
    return text;
  }

  String _normalize(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String _unescapeXml(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }
}

class _Token {
  _Token(this.index, this.value);
  final int index;
  final String value;
}
