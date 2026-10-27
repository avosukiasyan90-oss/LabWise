import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/models/medication.dart';
import 'package:healthy_project/services/medication_schedule.dart';

Medication med({
  required String id,
  String? title,
  List<DoseTime> times = const [DoseTime(hour: 9, minute: 0)],
  MedicationFrequency frequency = MedicationFrequency.daily,
  DateTime? start,
  DateTime? end,
  Set<String> taken = const {},
  int count = 1,
}) =>
    Medication(
      id: id,
      title: title ?? id,
      times: times,
      frequency: frequency,
      startDate: start ?? DateTime(2026, 10, 1),
      endDate: end,
      takenKeys: taken,
      count: count,
    );

void main() {
  const schedule = MedicationSchedule();
  final monday = DateTime(2026, 10, 26, 12, 0); // midday, so 09:00 is past

  group('when a dose falls due', () {
    test('a daily course is due every day from its start', () {
      final m = med(id: 'd', start: DateTime(2026, 10, 24));
      expect(m.fallsOn(DateTime(2026, 10, 24)), isTrue);
      expect(m.fallsOn(DateTime(2026, 10, 25)), isTrue);
      expect(m.fallsOn(DateTime(2026, 10, 26)), isTrue);
    });

    test('nothing is due before the start date', () {
      final m = med(id: 'd', start: DateTime(2026, 10, 25));
      expect(m.fallsOn(DateTime(2026, 10, 24)), isFalse);
    });

    test('every other day skips the days between', () {
      final m = med(
        id: 'eo',
        frequency: MedicationFrequency.everyOtherDay,
        start: DateTime(2026, 10, 24),
      );
      expect(m.fallsOn(DateTime(2026, 10, 24)), isTrue);
      expect(m.fallsOn(DateTime(2026, 10, 25)), isFalse);
      expect(m.fallsOn(DateTime(2026, 10, 26)), isTrue);
    });

    test('weekly lands on the same weekday', () {
      final m = med(
        id: 'w',
        frequency: MedicationFrequency.weekly,
        start: DateTime(2026, 10, 24),
      );
      expect(m.fallsOn(DateTime(2026, 10, 24)), isTrue);
      expect(m.fallsOn(DateTime(2026, 10, 30)), isFalse);
      expect(m.fallsOn(DateTime(2026, 10, 31)), isTrue);
    });

    test('as-needed is never scheduled', () {
      final m = med(id: 'prn', frequency: MedicationFrequency.asNeeded);
      expect(m.isScheduled, isFalse);
      expect(m.fallsOn(DateTime(2026, 10, 26)), isFalse);
      expect(m.nextDoseAfter(monday), isNull);
    });

    test('nothing is due after the end date', () {
      final m = med(
        id: 'd',
        start: DateTime(2026, 10, 20),
        end: DateTime(2026, 10, 25),
      );
      expect(m.fallsOn(DateTime(2026, 10, 25)), isTrue);
      expect(m.fallsOn(DateTime(2026, 10, 26)), isFalse);
    });
  });

  group('doses within a day', () {
    final twice = med(
      id: 'twice',
      times: const [DoseTime(hour: 20, minute: 0), DoseTime(hour: 8, minute: 0)],
    );

    test('come back in time order regardless of entry order', () {
      final doses = twice.dosesOn(monday, now: monday);
      expect(doses.map((d) => d.at.hour), [8, 20]);
    });

    test('a dose just past its time is due, not missed', () {
      // 08:00 dose seen at 08:05 — inside the ten minute grace window.
      final doses = twice.dosesOn(monday, now: DateTime(2026, 10, 26, 8, 5));
      expect(doses.first.isDueNow, isTrue);
      expect(doses.first.isOverdue, isFalse);
    });

    test('ten minutes is the cutoff between due and missed', () {
      final justInside =
          twice.dosesOn(monday, now: DateTime(2026, 10, 26, 8, 9)).first;
      expect(justInside.isDueNow, isTrue);
      expect(justInside.isOverdue, isFalse);

      final justOutside =
          twice.dosesOn(monday, now: DateTime(2026, 10, 26, 8, 10)).first;
      expect(justOutside.isDueNow, isFalse);
      expect(justOutside.isOverdue, isTrue);
    });

    test('a dose becomes missed once the grace window runs out', () {
      final doses = twice.dosesOn(monday, now: monday); // 12:00
      expect(doses.first.isOverdue, isTrue, reason: '08:00 is long past');
      expect(doses.first.isDueNow, isFalse);
      expect(doses.last.isOverdue, isFalse, reason: '20:00 is still ahead');
      expect(doses.last.isDueNow, isFalse);
    });

    test('a dose taken inside the window is neither due nor missed', () {
      final at = DateTime(2026, 10, 26, 8, 0);
      final doses = twice
          .markTaken(at, taken: true)
          .dosesOn(monday, now: DateTime(2026, 10, 26, 8, 5));
      expect(doses.first.isDueNow, isFalse);
      expect(doses.first.isOverdue, isFalse);
    });

    test('marking one taken does not affect the other', () {
      final at = DateTime(2026, 10, 26, 8, 0);
      final updated = twice.markTaken(at, taken: true);

      expect(updated.isTakenAt(at), isTrue);
      expect(updated.isTakenAt(DateTime(2026, 10, 26, 20, 0)), isFalse);
      expect(twice.isTakenAt(at), isFalse, reason: 'original is unchanged');
    });

    test('taking a dose can be undone', () {
      final at = DateTime(2026, 10, 26, 8, 0);
      final taken = twice.markTaken(at, taken: true);
      expect(taken.markTaken(at, taken: false).isTakenAt(at), isFalse);
    });

    test('the next dose skips ones already taken', () {
      final at = DateTime(2026, 10, 26, 20, 0);
      final updated = twice.markTaken(at, taken: true);
      final next = updated.nextDoseAfter(monday);

      expect(next, isNot(at));
      expect(next, DateTime(2026, 10, 27, 8, 0));
    });
  });

  group('ordering for the list', () {
    test('a dose inside its grace window sorts under missed, above upcoming',
        () {
      final medications = [
        med(id: 'upcoming', times: const [DoseTime(hour: 18, minute: 0)]),
        med(id: 'dueNow', times: const [DoseTime(hour: 11, minute: 55)]),
        med(id: 'missed', times: const [DoseTime(hour: 6, minute: 0)]),
      ];

      final ordered = schedule.ordered(medications, now: monday);
      expect(
        ordered.map((s) => s.medication.id),
        ['missed', 'dueNow', 'upcoming'],
      );
      expect(ordered[1].state, DoseState.dueNow);
    });

    test('missed first, then upcoming, then not-today, finished last', () {
      final medications = [
        med(id: 'done', times: const [DoseTime(hour: 8, minute: 0)], taken: {
          Medication.doseKey(DateTime(2026, 10, 26, 8, 0)),
        }),
        med(id: 'upcoming', times: const [DoseTime(hour: 18, minute: 0)]),
        med(
          id: 'notToday',
          frequency: MedicationFrequency.everyOtherDay,
          start: DateTime(2026, 10, 25),
        ),
        med(id: 'missed', times: const [DoseTime(hour: 7, minute: 0)]),
      ];

      final ordered = schedule.ordered(medications, now: monday);
      expect(
        ordered.map((s) => s.medication.id),
        ['missed', 'upcoming', 'notToday', 'done'],
      );
    });

    test('the longest outstanding dose sits at the very top', () {
      final medications = [
        med(id: 'missedLate', times: const [DoseTime(hour: 11, minute: 0)]),
        med(id: 'missedEarly', times: const [DoseTime(hour: 6, minute: 0)]),
      ];

      final ordered = schedule.ordered(medications, now: monday);
      expect(ordered.first.medication.id, 'missedEarly');
    });

    test('upcoming doses are ordered by whichever is due soonest', () {
      final medications = [
        med(id: 'evening', times: const [DoseTime(hour: 21, minute: 0)]),
        med(id: 'afternoon', times: const [DoseTime(hour: 14, minute: 0)]),
      ];

      final ordered = schedule.ordered(medications, now: monday);
      expect(
        ordered.map((s) => s.medication.id),
        ['afternoon', 'evening'],
      );
    });

    test('a finished course drops out of the list entirely', () {
      final medications = [
        med(id: 'current'),
        med(
          id: 'ended',
          start: DateTime(2026, 9, 1),
          end: DateTime(2026, 9, 30),
        ),
      ];

      final ordered = schedule.ordered(medications, now: monday);
      expect(ordered.map((s) => s.medication.id), ['current']);
    });

    test('same-state rows with no next dose fall back to alphabetical', () {
      final medications = [
        med(id: 'zinc', title: 'Zinc', frequency: MedicationFrequency.asNeeded),
        med(id: 'aspirin', title: 'Aspirin',
            frequency: MedicationFrequency.asNeeded),
      ];

      final ordered = schedule.ordered(medications, now: monday);
      expect(ordered.map((s) => s.medication.title), ['Aspirin', 'Zinc']);
    });
  });

  group('today at a glance', () {
    test('counts taken against total across every medicine', () {
      final medications = [
        med(id: 'a', times: const [
          DoseTime(hour: 8, minute: 0),
          DoseTime(hour: 20, minute: 0),
        ], taken: {
          Medication.doseKey(DateTime(2026, 10, 26, 8, 0)),
        }),
        med(id: 'b', times: const [DoseTime(hour: 9, minute: 0)]),
      ];

      final (taken, total) = schedule.progressToday(medications, now: monday);
      expect(taken, 1);
      expect(total, 3);
    });

    test('lists everything still to take, earliest first', () {
      final medications = [
        med(id: 'evening', times: const [DoseTime(hour: 20, minute: 0)]),
        med(id: 'morning', times: const [DoseTime(hour: 7, minute: 0)]),
      ];

      final remaining = schedule.remainingToday(medications, now: monday);
      expect(remaining.map((d) => d.medication.id), ['morning', 'evening']);
    });

    test('a complete day reports as done', () {
      final m = med(id: 'a', times: const [DoseTime(hour: 8, minute: 0)], taken: {
        Medication.doseKey(DateTime(2026, 10, 26, 8, 0)),
      });
      final status = schedule.statusFor(m, now: monday);

      expect(status.state, DoseState.done);
      expect(status.isComplete, isTrue);
    });
  });

  test('survives a save and reload', () {
    final original = med(
      id: 'vitd',
      title: 'Vitamin D',
      count: 2,
      times: const [DoseTime(hour: 8, minute: 30), DoseTime(hour: 21, minute: 0)],
      frequency: MedicationFrequency.everyOtherDay,
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 12, 31),
      taken: {Medication.doseKey(DateTime(2026, 10, 26, 8, 30))},
    );

    final restored = Medication.fromJson(original.toJson());

    expect(restored.title, 'Vitamin D');
    expect(restored.count, 2);
    expect(restored.times.map((t) => t.key), ['08:30', '21:00']);
    expect(restored.frequency, MedicationFrequency.everyOtherDay);
    expect(restored.endDate, DateTime(2026, 12, 31));
    expect(restored.isTakenAt(DateTime(2026, 10, 26, 8, 30)), isTrue);
  });
}
