import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/l10n/app_localizations.dart';
import 'package:healthy_project/models/lab_marker.dart';
import 'package:healthy_project/models/medical_report.dart';
import 'package:healthy_project/models/report_comparison.dart';
import 'package:healthy_project/screens/results_screen.dart';
import 'package:healthy_project/services/report_comparator.dart';

MedicalReport buildReport() => MedicalReport(
      id: 'new',
      fileName: 'biochemistry-may.pdf',
      uploadedAt: DateTime(2026, 5, 16, 10, 30),
      summary: 'Most values look settled.',
      whatToDo: const ['Keep up the walking.'],
      previous: ReportSnapshot(
        id: 'old',
        fileName: 'biochemistry-january.pdf',
        uploadedAt: DateTime(2026, 1, 10),
        markers: const [
          MarkerSnapshot(id: 'ldl', status: MarkerStatus.high, value: 200),
          MarkerSnapshot(id: 'hdl', status: MarkerStatus.low, value: 30),
          MarkerSnapshot(id: 'glucose', status: MarkerStatus.normal, value: 90),
        ],
      ),
      markers: const [
        LabMarker(
          id: 'ldl',
          name: 'LDL cholesterol',
          unit: 'mg/dL',
          status: MarkerStatus.normal,
          value: 150,
        ),
        LabMarker(
          id: 'hdl',
          name: 'HDL cholesterol',
          unit: 'mg/dL',
          status: MarkerStatus.low,
          value: 35,
        ),
        LabMarker(
          id: 'glucose',
          name: 'Glucose',
          unit: 'mg/dL',
          status: MarkerStatus.normal,
          value: 92,
        ),
      ],
    );

Widget host(MedicalReport report, Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: ResultsScreen(report: report),
    );

Future<void> scrollToChanges(WidgetTester tester) async {
  await tester.dragUntilVisible(
    find.text('What changed'),
    find.byType(CustomScrollView),
    const Offset(0, -220),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('results screen shows the comparison against the last test',
      (tester) async {
    await tester.pumpWidget(host(buildReport(), const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Compared with your last test'), findsOneWidget);
    expect(find.text('Better than last time'), findsOneWidget);
    expect(find.text('2 improved'), findsOneWidget);
    expect(find.text('1 steady'), findsOneWidget);
    expect(find.text('2 of 3 in range'), findsOneWidget);
    expect(find.text('was 1 of 3'), findsOneWidget);
    expect(find.text('+33 pts'), findsOneWidget);
  });

  testWidgets('lists each value that moved, with the size of the move',
      (tester) async {
    await tester.pumpWidget(host(buildReport(), const Locale('en')));
    await tester.pumpAndSettle();
    await scrollToChanges(tester);

    expect(find.text('What changed'), findsOneWidget);
    expect(find.text('-25%'), findsOneWidget);
    expect(find.text('+17%'), findsOneWidget);
    expect(find.text('Back in range'), findsOneWidget);
    // Steady values stay collapsed behind the toggle.
    expect(find.text('Show all 3 values'), findsOneWidget);
  });

  testWidgets('expanding reveals the values that held steady', (tester) async {
    await tester.pumpWidget(host(buildReport(), const Locale('en')));
    await tester.pumpAndSettle();
    await scrollToChanges(tester);

    await tester.tap(find.text('Show all 3 values'));
    await tester.pumpAndSettle();

    expect(find.text('Glucose'), findsOneWidget);
    expect(find.text('Show only what moved'), findsOneWidget);
  });

  testWidgets('renders in Russian without overflowing', (tester) async {
    await tester.pumpWidget(host(buildReport(), const Locale('ru')));
    await tester.pumpAndSettle();

    expect(find.text('Сравнение с прошлым анализом'), findsOneWidget);
    expect(find.text('Лучше, чем в прошлый раз'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a first-time report shows no comparison', (tester) async {
    final solo = buildReport().copyWith(fileName: 'first.pdf');
    final noPrevious = MedicalReport(
      id: solo.id,
      fileName: solo.fileName,
      uploadedAt: solo.uploadedAt,
      summary: solo.summary,
      whatToDo: solo.whatToDo,
      markers: solo.markers,
    );

    await tester.pumpWidget(host(noPrevious, const Locale('en')));
    await tester.pumpAndSettle();

    expect(const ReportComparator().compare(noPrevious), isNull);
    expect(find.text('Compared with your last test'), findsNothing);
    expect(find.text('What changed'), findsNothing);
  });
}
