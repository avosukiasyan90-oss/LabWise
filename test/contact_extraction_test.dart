import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/services/medical_analyzer.dart';

void main() {
  final analyzer = MedicalAnalyzer();

  test('reads the Armenian contact block and lab licence', () {
    final report = analyzer.analyze(
      fileName: 'biochem.pdf',
      text: File('test/fixtures/armenian_biochem_report.txt').readAsStringSync(),
    );

    expect(report.patientAddress, contains('ԵՐԵՎԱՆ'));
    expect(report.licenseNumber, contains('001536'));
    expect(report.hasContactDetails, isTrue);
  });

  test('reads the Russian contact block', () {
    final report = analyzer.analyze(
      fileName: 'main.pdf',
      text: File('test/fixtures/androflor_urogenital_report.txt')
          .readAsStringSync(),
    );

    expect(report.patientPhone, '93078780');
  });

  test('leaves contact fields null when the document has none', () {
    final report = analyzer.analyze(
      fileName: 'plain.pdf',
      text: 'Glucose\nmmol/L 4,11 - 5,89 5.80 GLUC',
    );

    expect(report.patientAddress, isNull);
    expect(report.patientPhone, isNull);
    expect(report.licenseNumber, isNull);
    expect(report.hasContactDetails, isFalse);
  });
}
