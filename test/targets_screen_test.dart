import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/l10n/app_localizations.dart';
import 'package:healthy_project/models/user_profile.dart';
import 'package:healthy_project/screens/targets_screen.dart';
import 'package:healthy_project/services/wellness_planner.dart';

void main() {
  final l10n = lookupAppL10n(const Locale('en'));

  Future<void> pump(WidgetTester tester, UserProfile profile) async {
    tester.view.physicalSize = const Size(1200, 3400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final plan = const WellnessPlanner().build(l10n: l10n, profile: profile);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: TargetsScreen(plan: plan, profile: profile),
      ),
    );
    await tester.pumpAndSettle();
  }

  // 95 kg at 176 cm is a BMI of 30.7 — the well-above band.
  const heavy = UserProfile(uid: 'u1', weightKg: 95, heightCm: 176, age: 36);

  testWidgets('shows the inputs every target was derived from', (tester) async {
    await pump(tester, heavy);

    expect(find.text('Worked out from'), findsOneWidget);
    expect(find.text('Weight 95.0 kg · Height 176.0 cm · Age 36'), findsOneWidget);
  });

  testWidgets('explains each of the four numbers', (tester) async {
    await pump(tester, heavy);

    expect(find.text('Body mass index'), findsOneWidget);
    expect(find.text('Daily calories'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);

    expect(find.text('30.7'), findsOneWidget);
    expect(find.text('Well above range'), findsOneWidget);
    // 95 kg x 0.033 rounded to one decimal.
    expect(find.text('3.1 L'), findsOneWidget);
  });

  testWidgets('names the calorie adjustment that was applied', (tester) async {
    await pump(tester, heavy);

    expect(
      find.text('500 kcal was removed for steady, sustainable loss.'),
      findsOneWidget,
    );
  });

  testWidgets('a healthy BMI is told no adjustment was made', (tester) async {
    await pump(
      tester,
      const UserProfile(uid: 'u1', weightKg: 68, heightCm: 176, age: 30),
    );

    expect(
      find.text('No adjustment — this is your maintenance level.'),
      findsOneWidget,
    );
  });

  testWidgets('is honest about what the numbers cannot know', (tester) async {
    await pump(tester, heavy);

    expect(
      find.textContaining('know nothing about your medical history'),
      findsOneWidget,
    );
    // The averaged-sex caveat is stated rather than hidden.
    expect(find.textContaining('averaged between the male and female'),
        findsOneWidget);
  });

  testWidgets('renders in Russian without overflowing', (tester) async {
    tester.view.physicalSize = const Size(1200, 3400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final plan = const WellnessPlanner().build(l10n: l10n, profile: heavy);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: TargetsScreen(plan: plan, profile: heavy),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Индекс массы тела'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
