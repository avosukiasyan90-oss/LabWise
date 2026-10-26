import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/services/medical_analyzer.dart';

void main() {
  late MedicalAnalyzer analyzer;

  setUp(() {
    analyzer = MedicalAnalyzer();
  });

  test('reads all 5 points from biochemical report', () {
    const text = '''
EXAMINATION REPORT № 646082
Patient SUKIASYAN AVETIK
BIOCHEMICAL EXAMINATION
Manipulation date 15/02/2025 11:13:34
Glucose
mmol/L 4,11 - 5,89 5.80 GLUC
Cholesterol
mmol/L No risk:    Moderate risk:       High risk:
<5.2            5.2 - 7.8                >7.8 6.36 CHOL
Triglycerides
mmol/L < 2,26 1.32 TRIGL
High-density lipoprotein
mmol/L No risk:    Moderate risk:       High risk:
>1.45         0.9 - 1.45             <0.9   1.33 HDL-C
Low-density lipoprotein
mmol/L Low risk:    Moderate risk:       High risk:
<2.6                <3.5                  >4.1   4.44 LDL-C
Method: photometric (cobas c311 JAPAN)
Doctor Shahinyan N.
''';

    final report = analyzer.analyze(fileName: 'lab.pdf', text: text);
    final byId = {for (final m in report.markers) m.id: m};

    expect(report.markers, hasLength(5));
    expect(byId['glucose']!.value, closeTo(5.80, 0.01));
    expect(byId['ldl']!.value, closeTo(4.44, 0.01));
  });

  test('reads all urinalysis strip points from newwww.pdf fixture', () {
    final fixture = File('test/fixtures/newwww_report.txt');
    expect(fixture.existsSync(), isTrue);

    final report = analyzer.analyze(
      fileName: 'newwww.pdf',
      text: fixture.readAsStringSync(),
    );
    final byId = {for (final m in report.markers) m.id: m};

    expect(report.examTitle?.toUpperCase(), contains('URINALYSIS'));
    expect(report.markers.length, greaterThanOrEqualTo(12));

    expect(byId['urine_color']!.displayResult.toLowerCase(), contains('yellow'));
    expect(byId['urine_transparency']!.displayResult.toLowerCase(),
        contains('transparent'));
    expect(byId['urine_sg']!.value, closeTo(1.021, 0.001));
    expect(byId['urine_ph']!.value, closeTo(5.5, 0.01));
    expect(byId['urine_leukocytes']!.displayResult.toLowerCase(), 'negative');
    expect(byId['urine_nitrites']!.displayResult.toLowerCase(), 'negative');
    expect(byId['urine_protein']!.displayResult.toLowerCase(), 'negative');
    expect(byId['urine_glucose']!.displayResult.toLowerCase(), 'negative');
    expect(byId['urine_ketones']!.displayResult.toLowerCase(), 'negative');
    expect(byId['urine_urobilinogen']!.displayResult.toLowerCase(), 'negative');
    expect(byId['urine_bilirubin']!.displayResult.toLowerCase(), 'negative');
    expect(byId['urine_erythrocytes']!.displayResult.toLowerCase(), 'negative');

    // Must not confuse urine glucose with blood glucose.
    expect(byId.containsKey('glucose'), isFalse);

    for (final marker in report.markers) {
      expect(marker.information, isNotEmpty);
      expect(marker.description, isNotEmpty);
      expect(marker.recommendation, isNotEmpty);
    }
  });

  test('recognizes markers from biochemical desktop PDF fixture', () {
    final fixture = File('test/fixtures/armenian_biochem_report.txt');
    expect(fixture.existsSync(), isTrue);
    final report = analyzer.analyze(
      fileName: '646082.pdf',
      text: fixture.readAsStringSync(),
    );
    expect(report.markers, hasLength(5));
  });

  test('reads all CBC points from complete blood count fixture', () {
    final fixture = File('test/fixtures/cbc_report.txt');
    expect(fixture.existsSync(), isTrue);

    final report = analyzer.analyze(
      fileName: 'cbc.pdf',
      text: fixture.readAsStringSync(),
    );
    final byId = {for (final m in report.markers) m.id: m};

    expect(report.examTitle?.toUpperCase(), contains('COMPLETE BLOOD COUNT'));
    expect(report.markers.length, greaterThanOrEqualTo(25));

    expect(byId['wbc']!.value, closeTo(8.76, 0.01));
    expect(byId['rbc']!.value, closeTo(5.44, 0.01));
    expect(byId['hemoglobin']!.value, closeTo(16.0, 0.01));
    expect(byId['hct']!.value, closeTo(48.5, 0.01));
    expect(byId['mcv']!.value, closeTo(89.2, 0.01));
    expect(byId['mch']!.value, closeTo(29.4, 0.01));
    expect(byId['mchc']!.value, closeTo(33.0, 0.01));
    expect(byId['platelets']!.value, closeTo(242, 0.1));
    expect(byId['rdw_sd']!.value, closeTo(39.0, 0.01));
    expect(byId['rdw_cv']!.value, closeTo(12.0, 0.01));
    expect(byId['pdw']!.value, closeTo(12.3, 0.01));
    expect(byId['mpv']!.value, closeTo(10.7, 0.01));
    expect(byId['p_lcr']!.value, closeTo(29.7, 0.01));
    expect(byId['pct']!.value, closeTo(0.26, 0.01));
    expect(byId['neut_pct']!.value, closeTo(51.2, 0.01));
    expect(byId['lymph_pct']!.value, closeTo(40.9, 0.01));
    expect(byId['mono_pct']!.value, closeTo(6.7, 0.01));
    expect(byId['eo_pct']!.value, closeTo(0.9, 0.01));
    expect(byId['baso_pct']!.value, closeTo(0.3, 0.01));
    expect(byId['neut_abs']!.value, closeTo(4.48, 0.01));
    expect(byId['lymph_abs']!.value, closeTo(3.58, 0.01));
    expect(byId['mono_abs']!.value, closeTo(0.59, 0.01));
    expect(byId['eo_abs']!.value, closeTo(0.08, 0.01));
    expect(byId['baso_abs']!.value, closeTo(0.03, 0.01));
    expect(byId['esr']!.value, closeTo(1, 0.01));

    expect(byId['mpv']!.status.name, 'high');
    expect(byId['lymph_abs']!.status.name, 'high');
  });

  test('reads Androflor + urogenital smear microscopy fixture', () {
    final fixture = File('test/fixtures/androflor_urogenital_report.txt');
    expect(fixture.existsSync(), isTrue);

    final report = analyzer.analyze(
      fileName: 'main.pdf',
      text: fixture.readAsStringSync(),
    );
    final byId = {for (final m in report.markers) m.id: m};

    expect(report.markers.length, greaterThanOrEqualTo(20));
    expect(report.patientName, contains('Аветик'));
    expect(report.reportNumber, '871380');

    expect(byId['uro_leukocytes']!.displayResult, contains('0-2'));
    expect(byId['uro_gonorrhea_smear']!.displayResult.toLowerCase(),
        contains('not detected'));
    expect(byId['af_chlamydia']!.displayResult.toLowerCase(),
        contains('not detected'));
    expect(byId['af_ureaplasma_parvum']!.displayResult, contains('10^'));
    expect(byId['af_ureaplasma_parvum']!.isAbnormal, isTrue);
    expect(byId['af_normoflora_sum']!.displayResult, contains('%'));
    expect(byId['af_normoflora_sum']!.isAbnormal, isTrue);

    for (final marker in report.markers) {
      expect(marker.information, isNotEmpty);
      expect(marker.description, isNotEmpty);
      expect(marker.recommendation, isNotEmpty);
    }
  });
}
