import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/models/lab_marker.dart';
import 'package:healthy_project/models/report_category.dart';
import 'package:healthy_project/services/medical_analyzer.dart';

void main() {
  final analyzer = MedicalAnalyzer();
  final fixture =
      File('test/fixtures/helicobacter_breath_test.txt').readAsStringSync();

  test('reads a negative Helik breath test from the real report', () {
    final report = analyzer.analyze(fileName: 'helik.pdf', text: fixture);
    final marker =
        report.markers.firstWhere((m) => m.id == 'h_pylori');

    expect(marker.displayResult, 'Negative');
    expect(marker.status, MarkerStatus.normal);
    expect(marker.isAbnormal, isFalse);
    expect(marker.information, isNotEmpty);
    expect(marker.recommendation, isNotEmpty);
  });

  test('picks up the clinic, patient, and test method', () {
    final report = analyzer.analyze(fileName: 'helik.pdf', text: fixture);

    expect(report.clinicName, contains('ՎԱՐԴԱՆԱՆՑ'));
    expect(report.patientName, contains('ՍՈՒՔԻԱՍՅԱՆ'));
    expect(report.examTitle?.toLowerCase(), contains('հելիկ'));
    expect(report.sampleDate, '16.05.2026');
    expect(report.patientPhone, '+37493078780');
    // The isotope label wraps across lines in the PDF.
    expect(report.method, 'Heliforce Urea / 13C');
  });

  test('files the report under Infection Tests', () {
    final report = analyzer.analyze(fileName: 'helik.pdf', text: fixture);
    expect(categoryOf(report), ReportCategory.infection);
  });

  test('does not mine the consent page for stray assay codes', () {
    final report = analyzer.analyze(fileName: 'helik.pdf', text: fixture);
    expect(report.markers, hasLength(1));
  });

  test('reads a positive result when the tick sits by Դրական', () {
    final positive = fixture.replaceFirst(
      'Բացասական \n  \n✓\n         \n Դրական',
      'Բացասական \n  \n         \n Դրական ✓',
    );
    final report = analyzer.analyze(fileName: 'helik.pdf', text: positive);
    final marker = report.markers.firstWhere((m) => m.id == 'h_pylori');

    expect(marker.displayResult, 'Positive');
    expect(marker.status, MarkerStatus.high);
    expect(marker.isAbnormal, isTrue);
  });

  test('understands the English wording too', () {
    const text = '''
Helicobacter pylori Urea Breath Test
Conclusion
Negative        Positive  ✓
''';
    final report = analyzer.analyze(fileName: 'ubt.pdf', text: text);
    final marker = report.markers.firstWhere((m) => m.id == 'h_pylori');

    expect(marker.displayResult, 'Positive');
  });
}
