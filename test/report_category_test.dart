import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/models/medical_report.dart';
import 'package:healthy_project/models/report_category.dart';
import 'package:healthy_project/services/medical_analyzer.dart';

void main() {
  final analyzer = MedicalAnalyzer();

  MedicalReport fromFixture(String file, String name) => analyzer.analyze(
        fileName: name,
        text: File('test/fixtures/$file').readAsStringSync(),
      );

  test('files each fixture into the right folder', () {
    expect(
      categoryOf(fromFixture('cbc_report.txt', 'cbc.pdf')),
      ReportCategory.bloodCount,
    );
    expect(
      categoryOf(fromFixture('armenian_biochem_report.txt', 'biochem.pdf')),
      ReportCategory.biochemistry,
    );
    expect(
      categoryOf(fromFixture('newwww_report.txt', 'urine.pdf')),
      ReportCategory.urinalysis,
    );
    expect(
      categoryOf(fromFixture('androflor_urogenital_report.txt', 'main.pdf')),
      ReportCategory.urogenital,
    );
  });

  test('falls back to Other when nothing was recognized', () {
    final report = MedicalReport(
      id: 'r1',
      fileName: 'scan.pdf',
      uploadedAt: DateTime(2026, 10, 1),
      summary: '',
      whatToDo: const [],
      markers: const [],
    );

    expect(categoryOf(report), ReportCategory.other);
  });

  test('groups folders newest-first with reports sorted inside', () {
    MedicalReport urine(String id, DateTime at) => analyzer
        .analyze(
          fileName: '$id.pdf',
          text: File('test/fixtures/newwww_report.txt').readAsStringSync(),
        )
        .copyWith(id: id, uploadedAt: at);

    final cbc = fromFixture('cbc_report.txt', 'cbc.pdf')
        .copyWith(uploadedAt: DateTime(2026, 1, 1));

    final folders = groupByCategory([
      cbc,
      urine('old', DateTime(2026, 5, 1)),
      urine('new', DateTime(2026, 9, 1)),
    ]);

    expect(folders.first.key, ReportCategory.urinalysis);
    expect(folders.first.value.map((r) => r.id), ['new', 'old']);
    expect(folders.last.key, ReportCategory.bloodCount);
  });
}
