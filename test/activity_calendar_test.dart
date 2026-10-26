import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/l10n/app_localizations.dart';
import 'package:healthy_project/models/daily_activity.dart';
import 'package:healthy_project/screens/activity_screen.dart';
import 'package:healthy_project/services/activity_controller.dart';
import 'package:healthy_project/services/activity_store.dart';
import 'package:healthy_project/services/health_service.dart';
import 'package:healthy_project/widgets/activity_calendar.dart';
import 'package:healthy_project/widgets/activity_summary_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for a phone whose health store is connected and has history.
class _ConnectedHealth extends HealthService {
  _ConnectedHealth(this.days);

  final Map<DateTime, DailyActivity> days;
  int permissionRequests = 0;

  @override
  bool get isSupported => true;

  @override
  Future<HealthAvailability> availability() async => HealthAvailability.ready;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<Map<DateTime, DailyActivity>> fetchRange({
    required DateTime from,
    required DateTime to,
  }) async =>
      days;
}

/// Stands in for a phone where the user has not granted access yet.
class _UnconnectedHealth extends HealthService {
  int permissionRequests = 0;
  bool granted = false;

  @override
  bool get isSupported => true;

  @override
  Future<HealthAvailability> availability() async => granted
      ? HealthAvailability.ready
      : HealthAvailability.needsPermission;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    granted = true;
    return true;
  }

  @override
  Future<Map<DateTime, DailyActivity>> fetchRange({
    required DateTime from,
    required DateTime to,
  }) async =>
      {};
}

/// Counts how many times the month range was actually fetched.
class _CountingHealth extends _ConnectedHealth {
  _CountingHealth(super.days);

  int fetches = 0;

  @override
  Future<Map<DateTime, DailyActivity>> fetchRange({
    required DateTime from,
    required DateTime to,
  }) async {
    fetches++;
    return days;
  }
}

/// A phone where the plugin was added after this binary was built.
class _StalePluginHealth extends HealthService {
  @override
  bool get isSupported => true;

  @override
  Future<HealthAvailability> availability() async =>
      HealthAvailability.pluginMissing;
}

void main() {
  late ActivityStore store;

  final today = DailyActivity.dayKey(DateTime.now());
  final yesterday = today.subtract(const Duration(days: 1));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await ActivityStore.create();
  });

  ActivityController controllerFor(HealthService health) =>
      ActivityController(healthService: health, store: store);

  Future<void> pump(WidgetTester tester, HealthService health) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ActivityCalendar(
              controller: controllerFor(health),
              stepGoal: 9000,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The Plan tab: compact card that opens the calendar on tap.
  Future<void> pumpSummary(WidgetTester tester, HealthService health) async {
    final controller = controllerFor(health);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: SingleChildScrollView(
              child: ActivitySummaryCard(
                controller: controller,
                stepGoal: 9000,
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActivityScreen(controller: controller),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the connect prompt until access is granted',
      (tester) async {
    await pump(tester, _UnconnectedHealth());

    expect(find.text('Connect your activity'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
    // No calendar grid while disconnected.
    expect(find.text('Workouts'), findsNothing);
  });

  testWidgets('tapping Connect asks the system and then shows the calendar',
      (tester) async {
    final health = _UnconnectedHealth();
    await pump(tester, health);

    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(health.permissionRequests, 1);
    expect(find.text('Connect your activity'), findsNothing);
    // The calendar replaces the prompt and defaults to today.
    expect(find.text('No movement recorded on this day.'), findsOneWidget);
  });

  testWidgets('shows a calendar instead of the prompt once connected',
      (tester) async {
    await pump(
      tester,
      _ConnectedHealth({
        today: DailyActivity(
          day: today,
          steps: 11240,
          walkRunKm: 7.8,
          activeMinutes: 65,
          activeKcal: 430,
        ),
      }),
    );

    expect(find.text('Connect your activity'), findsNothing);
    expect(find.text('11240'), findsOneWidget);
  });

  testWidgets('opens the details for whichever day is tapped', (tester) async {
    await pump(
      tester,
      _ConnectedHealth({
        today: DailyActivity(day: today, steps: 3000, walkRunKm: 2.0),
        yesterday: DailyActivity(
          day: yesterday,
          steps: 14800,
          walkRunKm: 4.2,
          cycleKm: 23.6,
          activeMinutes: 96,
          activeKcal: 880,
          sessions: [
            ActivitySession(
              kind: ActivityKind.cycling,
              start: yesterday.add(const Duration(hours: 18)),
              end: yesterday.add(const Duration(hours: 19, minutes: 12)),
              km: 23.6,
              kcal: 640,
            ),
          ],
        ),
      }),
    );

    // Today is selected by default.
    expect(find.text('3000'), findsOneWidget);

    await tester.tap(find.text('${yesterday.day}').first);
    await tester.pumpAndSettle();

    // Steps, total distance, active minutes, and energy for that day.
    expect(find.text('14800'), findsOneWidget);
    expect(find.text('27.8 km'), findsOneWidget);
    expect(find.text('96'), findsOneWidget);
    expect(find.text('880'), findsOneWidget);
  });

  testWidgets('splits walking from cycling and lists the workout',
      (tester) async {
    await pump(
      tester,
      _ConnectedHealth({
        today: DailyActivity(
          day: today,
          steps: 14800,
          walkRunKm: 4.2,
          cycleKm: 23.6,
          activeMinutes: 96,
          activeKcal: 880,
          sessions: [
            ActivitySession(
              kind: ActivityKind.cycling,
              start: today.add(const Duration(hours: 18)),
              end: today.add(const Duration(hours: 19, minutes: 12)),
              km: 23.6,
              kcal: 640,
            ),
          ],
        ),
      }),
    );

    expect(find.text('Walking & running'), findsOneWidget);
    expect(find.text('4.2 km'), findsOneWidget);
    expect(find.text('Cycling'), findsOneWidget);
    expect(find.text('23.6 km'), findsOneWidget);

    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Cycle'), findsOneWidget);
    expect(find.textContaining('72 min'), findsOneWidget);
    expect(find.textContaining('640 kcal'), findsOneWidget);
  });

  testWidgets('says so plainly on a day with nothing recorded', (tester) async {
    await pump(tester, _ConnectedHealth({yesterday: DailyActivity(day: yesterday, steps: 500)}));

    expect(find.text('No movement recorded on this day.'), findsOneWidget);
  });

  testWidgets('asks for a relaunch when the plugin is not registered',
      (tester) async {
    await pump(tester, _StalePluginHealth());

    expect(find.textContaining('Fully close the app'), findsOneWidget);
    expect(find.text('Connect your activity'), findsNothing);
  });

  testWidgets('renders the day detail in Russian', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ActivityCalendar(
              controller: controllerFor(
                _ConnectedHealth({
                  today: DailyActivity(day: today, steps: 9100, cycleKm: 12.0),
                }),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Велосипед'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  group('Plan tab summary card', () {
    testWidgets('shows today at a glance instead of a month grid',
        (tester) async {
      await pumpSummary(
        tester,
        _ConnectedHealth({
          today: DailyActivity(
            day: today,
            steps: 9400,
            walkRunKm: 6.1,
            activeMinutes: 48,
          ),
        }),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('9400'), findsOneWidget);
      expect(find.text('6.1 km'), findsOneWidget);
      expect(find.text('48 min'), findsOneWidget);
      // The full grid stays on the pushed screen.
      expect(find.byType(ActivityCalendar), findsNothing);
      expect(find.text('Workouts'), findsNothing);
    });

    testWidgets('opens the full calendar when tapped', (tester) async {
      await pumpSummary(
        tester,
        _ConnectedHealth({
          today: DailyActivity(day: today, steps: 9400, walkRunKm: 6.1),
        }),
      );

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityCalendar), findsOneWidget);
      expect(find.text('Tap any day to see what you did'), findsOneWidget);
    });

    testWidgets('offers a one-line connect row while disconnected',
        (tester) async {
      final health = _UnconnectedHealth();
      await pumpSummary(tester, health);

      expect(find.text('Connect your activity'), findsOneWidget);
      expect(find.text('Read-only, stays on your phone'), findsOneWidget);

      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      expect(health.permissionRequests, 1);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('both views share one controller, so no double fetch',
        (tester) async {
      final health = _CountingHealth({today: DailyActivity(day: today, steps: 100)});
      final controller = controllerFor(health);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ActivitySummaryCard(
                    controller: controller,
                    onOpen: () {},
                  ),
                  ActivityCalendar(controller: controller),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(health.fetches, 1);
    });
  });
}
