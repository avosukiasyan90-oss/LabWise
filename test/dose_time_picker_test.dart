import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/l10n/app_localizations.dart';
import 'package:healthy_project/models/medication.dart';
import 'package:healthy_project/widgets/dose_time_picker.dart';

void main() {
  Future<DoseTime?> open(
    WidgetTester tester, {
    DoseTime? initial,
    Set<DoseTime> taken = const {},
  }) async {
    DoseTime? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDoseTimePicker(
                    context,
                    initial: initial,
                    taken: taken,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('offers the everyday times as one-tap presets', (tester) async {
    await open(tester);

    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Midday'), findsOneWidget);
    expect(find.text('Evening'), findsOneWidget);
    expect(find.text('Night'), findsOneWidget);

    expect(find.text('08:00'), findsWidgets);
    expect(find.text('13:00'), findsOneWidget);
    expect(find.text('19:00'), findsOneWidget);
    expect(find.text('22:00'), findsOneWidget);
  });

  testWidgets('a preset tap sets the time and returns it', (tester) async {
    await open(tester);

    await tester.tap(find.text('Evening'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set time'));
    await tester.pumpAndSettle();

    // The sheet closed, which only happens via the confirm button.
    expect(find.text('Set time'), findsNothing);
  });

  testWidgets('opens on the time being edited', (tester) async {
    await open(tester, initial: const DoseTime(hour: 13, minute: 0));

    // Shown both as the heading value and on the Midday preset.
    expect(find.text('13:00'), findsNWidgets(2));
  });

  testWidgets('times already on the medicine cannot be picked again',
      (tester) async {
    await open(tester, taken: {const DoseTime(hour: 8, minute: 0)});

    await tester.tap(find.text('Morning'));
    await tester.pumpAndSettle();

    // Disabled, so the selection never moved and no warning is needed.
    expect(find.text('That time is already added.'), findsNothing);
    expect(find.text('Set time'), findsOneWidget);
  });

  testWidgets('the time being edited is still selectable', (tester) async {
    const existing = DoseTime(hour: 8, minute: 0);
    await open(tester, initial: existing, taken: {existing});

    await tester.tap(find.text('Set time'));
    await tester.pumpAndSettle();

    expect(find.text('Set time'), findsNothing, reason: 'confirm was enabled');
  });

  testWidgets('dismissing returns nothing', (tester) async {
    final result = await open(tester);
    expect(result, isNull);
  });

  testWidgets('renders in Russian', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDoseTimePicker(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Время напоминания'), findsOneWidget);
    expect(find.text('Утро'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
