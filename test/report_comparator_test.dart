import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/models/lab_marker.dart';
import 'package:healthy_project/models/medical_report.dart';
import 'package:healthy_project/models/report_comparison.dart';
import 'package:healthy_project/services/report_comparator.dart';

LabMarker marker(
  String id, {
  double? value,
  String? text,
  MarkerStatus status = MarkerStatus.normal,
}) =>
    LabMarker(
      id: id,
      name: id,
      unit: 'mg/dL',
      status: status,
      value: value,
      resultText: text,
    );

MedicalReport report({
  required String id,
  required List<LabMarker> markers,
  DateTime? at,
  ReportSnapshot? previous,
}) =>
    MedicalReport(
      id: id,
      fileName: '$id.pdf',
      uploadedAt: at ?? DateTime(2026, 5, 16),
      summary: '',
      whatToDo: const [],
      markers: markers,
      previous: previous,
    );

void main() {
  const comparator = ReportComparator();

  group('finding the earlier run of a test', () {
    test('matches a repeat of the same panel', () {
      final old = report(
        id: 'old',
        at: DateTime(2026, 1, 10),
        markers: [marker('glucose'), marker('ldl'), marker('hdl')],
      );
      final fresh = report(
        id: 'new',
        markers: [marker('glucose'), marker('ldl'), marker('hdl')],
      );

      expect(comparator.findPreviousInSeries(fresh, [old])?.id, 'old');
    });

    test('tolerates a lab dropping one marker between visits', () {
      final old = report(
        id: 'old',
        at: DateTime(2026, 1, 10),
        markers: [
          marker('glucose'),
          marker('ldl'),
          marker('hdl'),
          marker('triglycerides'),
        ],
      );
      final fresh = report(
        id: 'new',
        markers: [marker('glucose'), marker('ldl'), marker('hdl')],
      );

      expect(comparator.findPreviousInSeries(fresh, [old])?.id, 'old');
    });

    test('does not match a different kind of test', () {
      final blood = report(
        id: 'cbc',
        at: DateTime(2026, 1, 10),
        markers: [marker('hemoglobin'), marker('wbc'), marker('platelets')],
      );
      final chemistry = report(
        id: 'biochem',
        markers: [marker('glucose'), marker('ldl'), marker('hdl')],
      );

      expect(comparator.findPreviousInSeries(chemistry, [blood]), isNull);
    });

    test('picks the most recent run when several exist', () {
      final markers = [marker('glucose'), marker('ldl'), marker('hdl')];
      final older = report(id: 'older', at: DateTime(2025, 6, 1), markers: markers);
      final recent = report(id: 'recent', at: DateTime(2026, 1, 10), markers: markers);
      final fresh = report(id: 'new', markers: markers);

      expect(
        comparator.findPreviousInSeries(fresh, [older, recent])?.id,
        'recent',
      );
    });

    test('returns nothing for the first test of its kind', () {
      final fresh = report(id: 'new', markers: [marker('glucose')]);
      expect(comparator.findPreviousInSeries(fresh, []), isNull);
    });
  });

  group('direction of each value', () {
    MarkerSnapshot was(double? v, MarkerStatus s, {String? text}) =>
        MarkerSnapshot(id: 'x', status: s, value: v, resultText: text);

    test('coming back into range is an improvement', () {
      expect(
        ReportComparator.directionFor(
          previous: was(240, MarkerStatus.high),
          current: marker('x', value: 180, status: MarkerStatus.normal),
        ),
        TrendDirection.improved,
      );
    });

    test('falling out of range is a decline', () {
      expect(
        ReportComparator.directionFor(
          previous: was(180, MarkerStatus.normal),
          current: marker('x', value: 240, status: MarkerStatus.high),
        ),
        TrendDirection.worsened,
      );
    });

    test('a high value dropping is progress even while still high', () {
      expect(
        ReportComparator.directionFor(
          previous: was(300, MarkerStatus.high),
          current: marker('x', value: 250, status: MarkerStatus.high),
        ),
        TrendDirection.improved,
      );
    });

    test('a low value falling further is a decline', () {
      expect(
        ReportComparator.directionFor(
          previous: was(10, MarkerStatus.low),
          current: marker('x', value: 8, status: MarkerStatus.low),
        ),
        TrendDirection.worsened,
      );
    });

    test('overshooting from low to high is not progress', () {
      expect(
        ReportComparator.directionFor(
          previous: was(2, MarkerStatus.low),
          current: marker('x', value: 90, status: MarkerStatus.high),
        ),
        TrendDirection.worsened,
      );
    });

    test('two in-range values count as steady however they moved', () {
      expect(
        ReportComparator.directionFor(
          previous: was(90, MarkerStatus.normal),
          current: marker('x', value: 100, status: MarkerStatus.normal),
        ),
        TrendDirection.steady,
      );
    });

    test('an ungraded value claims nothing', () {
      expect(
        ReportComparator.directionFor(
          previous: was(null, MarkerStatus.unknown, text: 'Trace'),
          current: marker('x', text: 'Trace', status: MarkerStatus.unknown),
        ),
        TrendDirection.steady,
      );
    });

    test('a positive infection turning negative is an improvement', () {
      expect(
        ReportComparator.directionFor(
          previous: was(null, MarkerStatus.high, text: 'Positive'),
          current: marker('x', text: 'Negative', status: MarkerStatus.normal),
        ),
        TrendDirection.improved,
      );
    });
  });

  group('comparing a report with the one it replaced', () {
    final previous = ReportSnapshot(
      id: 'old',
      fileName: 'old.pdf',
      uploadedAt: DateTime(2026, 1, 10),
      markers: [
        MarkerSnapshot(id: 'ldl', status: MarkerStatus.high, value: 200),
        MarkerSnapshot(id: 'hdl', status: MarkerStatus.low, value: 30),
        MarkerSnapshot(id: 'glucose', status: MarkerStatus.normal, value: 90),
        MarkerSnapshot(id: 'tsh', status: MarkerStatus.normal, value: 2),
      ],
    );

    final current = report(
      id: 'new',
      previous: previous,
      markers: [
        marker('ldl', value: 150, status: MarkerStatus.normal),
        marker('hdl', value: 35, status: MarkerStatus.low),
        marker('glucose', value: 92, status: MarkerStatus.normal),
        marker('tsh', value: 8, status: MarkerStatus.high),
      ],
    );

    test('scores only the markers present in both reports', () {
      final result = comparator.compare(current)!;
      expect(result.comparedCount, 4);
      expect(result.previousInRange, 2);
      expect(result.currentInRange, 2);
      expect(result.scoreChange, 0);
    });

    test('sorts each value into improved, declined, or steady', () {
      final result = comparator.compare(current)!;
      expect(result.improved.map((d) => d.name), ['ldl', 'hdl']);
      expect(result.worsened.map((d) => d.name), ['tsh']);
      expect(result.steady.map((d) => d.name), ['glucose']);
      expect(result.overall, TrendDirection.improved);
    });

    test('reports how far each value moved', () {
      final result = comparator.compare(current)!;
      final ldl = result.deltas.firstWhere((d) => d.name == 'ldl');

      expect(ldl.change, -50);
      expect(ldl.percentChange, -25);
      expect(ldl.enteredRange, isTrue);

      final tsh = result.deltas.firstWhere((d) => d.name == 'tsh');
      expect(tsh.leftRange, isTrue);
    });

    test('ignores markers only one of the two tests measured', () {
      final extra = report(
        id: 'new',
        previous: previous,
        markers: [
          marker('ldl', value: 150, status: MarkerStatus.normal),
          marker('vitamin_d', value: 40, status: MarkerStatus.normal),
        ],
      );
      final result = comparator.compare(extra)!;
      expect(result.deltas.map((d) => d.name), ['ldl']);
    });

    test('a report that replaced nothing has no comparison', () {
      expect(comparator.compare(report(id: 'solo', markers: [marker('ldl')])),
          isNull);
    });

    test('shows every value when none of them moved', () {
      final unchanged = report(
        id: 'new',
        previous: previous,
        markers: [
          marker('glucose', value: 90, status: MarkerStatus.normal),
          marker('tsh', value: 2, status: MarkerStatus.normal),
        ],
      );
      final result = comparator.compare(unchanged)!;
      expect(result.overall, TrendDirection.steady);
      expect(result.notable, hasLength(2));
    });
  });

  test('the replaced report survives a save and reload', () {
    final original = report(
      id: 'new',
      previous: ReportSnapshot(
        id: 'old',
        fileName: 'old.pdf',
        uploadedAt: DateTime(2026, 1, 10),
        markers: [
          MarkerSnapshot(id: 'ldl', status: MarkerStatus.high, value: 200),
        ],
      ),
      markers: [marker('ldl', value: 150, status: MarkerStatus.normal)],
    );

    final restored = MedicalReport.fromJson(original.toJson());
    final result = comparator.compare(restored)!;

    expect(restored.supersedesPrevious, isTrue);
    expect(restored.previous!.fileName, 'old.pdf');
    expect(result.improved, hasLength(1));
    expect(result.deltas.single.percentChange, -25);
  });
}
