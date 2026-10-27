import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/l10n/app_localizations.dart';
import 'package:healthy_project/models/lab_marker.dart';
import 'package:healthy_project/models/medical_report.dart';
import 'package:healthy_project/widgets/report_summary_card.dart';

LabMarker marker(MarkerStatus status, [String id = 'x']) => LabMarker(
      id: id,
      name: id,
      unit: 'mg/dL',
      status: status,
      value: 1,
    );

MedicalReport report({
  required List<LabMarker> markers,
  String summary = 'Most values look settled this time around.',
}) =>
    MedicalReport(
      id: 'r1',
      fileName: 'biochemistry.pdf',
      uploadedAt: DateTime(2026, 5, 16, 10, 30),
      summary: summary,
      whatToDo: const [],
      markers: markers,
    );

Future<void> pump(WidgetTester tester, MedicalReport r) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ReportSummaryCard(report: r, onTap: () {}),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an all-clear report collapses to one compact row',
      (tester) async {
    await pump(
      tester,
      report(markers: List.filled(24, marker(MarkerStatus.normal))),
    );

    expect(find.text('Looking good'), findsOneWidget);
    // Date and marker count share one line in the compact layout.
    expect(find.textContaining('24 markers'), findsOneWidget);

    // The parts that say nothing for a normal result are gone.
    expect(find.text('Most values look settled this time around.'), findsNothing);
    expect(find.text('0 to review'), findsNothing);
  });

  testWidgets('a report needing attention keeps the full card', (tester) async {
    await pump(
      tester,
      report(markers: [
        marker(MarkerStatus.high, 'ldl'),
        marker(MarkerStatus.low, 'hdl'),
        marker(MarkerStatus.normal, 'glucose'),
      ]),
    );

    expect(find.text('Most values look settled this time around.'),
        findsOneWidget);
    expect(find.text('2 to review'), findsOneWidget);
    expect(find.text('3 markers'), findsOneWidget);
  });

  testWidgets('the compact row is shorter than the full card', (tester) async {
    final clear = report(markers: List.filled(10, marker(MarkerStatus.normal)));
    await pump(tester, clear);
    final compactHeight = tester.getSize(find.byType(ReportSummaryCard)).height;

    final flagged = report(markers: [
      marker(MarkerStatus.high, 'ldl'),
      ...List.filled(9, marker(MarkerStatus.normal)),
    ]);
    await pump(tester, flagged);
    final fullHeight = tester.getSize(find.byType(ReportSummaryCard)).height;

    expect(compactHeight, lessThan(fullHeight));
  });

  testWidgets('a report with no readable markers still shows its summary',
      (tester) async {
    // Nothing parsed is not the same as nothing wrong, so this keeps the
    // detailed layout and the explanation that comes with it.
    await pump(tester, report(markers: const []));

    expect(find.text('Most values look settled this time around.'),
        findsOneWidget);
  });

  testWidgets('renders compactly in Russian too', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReportSummaryCard(
              report:
                  report(markers: List.filled(12, marker(MarkerStatus.normal))),
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
