import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/models/daily_activity.dart';

void main() {
  group('day keys', () {
    test('collapses a timestamp to local midnight', () {
      final key = DailyActivity.dayKey(DateTime(2026, 5, 16, 23, 59, 58));
      expect(key, DateTime(2026, 5, 16));
    });

    test('two times on the same day share one key', () {
      expect(
        DailyActivity.dayKey(DateTime(2026, 5, 16, 1)),
        DailyActivity.dayKey(DateTime(2026, 5, 16, 22)),
      );
    });
  });

  group('a day of movement', () {
    final day = DailyActivity(
      day: DateTime(2026, 5, 16),
      steps: 9400,
      walkRunKm: 6.2,
      cycleKm: 12.5,
      activeMinutes: 74,
      activeKcal: 610,
      sessions: [
        ActivitySession(
          kind: ActivityKind.cycling,
          start: DateTime(2026, 5, 16, 18, 0),
          end: DateTime(2026, 5, 16, 18, 45),
          km: 12.5,
          kcal: 380,
        ),
      ],
    );

    test('adds walking and cycling into one distance', () {
      expect(day.totalKm, closeTo(18.7, 0.001));
    });

    test('counts as movement', () {
      expect(day.hasMovement, isTrue);
      expect(day.isEmpty, isFalse);
    });

    test('reports how long each workout lasted', () {
      expect(day.sessions.single.duration, const Duration(minutes: 45));
    });

    test('survives a save and reload', () {
      final restored = DailyActivity.fromJson(day.toJson());

      expect(restored.day, day.day);
      expect(restored.steps, 9400);
      expect(restored.walkRunKm, closeTo(6.2, 0.001));
      expect(restored.cycleKm, closeTo(12.5, 0.001));
      expect(restored.activeMinutes, 74);
      expect(restored.activeKcal, 610);
      expect(restored.sessions.single.kind, ActivityKind.cycling);
      expect(restored.sessions.single.km, closeTo(12.5, 0.001));
      expect(restored.sessions.single.duration, const Duration(minutes: 45));
    });
  });

  test('a day with nothing recorded reads as empty', () {
    final day = DailyActivity(day: DateTime(2026, 5, 16));
    expect(day.isEmpty, isTrue);
    expect(day.hasMovement, isFalse);
    expect(day.totalKm, 0);
  });

  test('an unknown workout kind falls back rather than throwing', () {
    expect(ActivityKind.fromName('swimming'), ActivityKind.other);
    expect(ActivityKind.fromName(null), ActivityKind.other);
    expect(ActivityKind.fromName('cycling'), ActivityKind.cycling);
  });
}
