import '../models/medication.dart';

/// Where a medication sits in today's list.
enum DoseState {
  /// Past its time and the grace window, still not taken.
  overdue,

  /// Due right now, inside the grace window.
  dueNow,

  /// Still to come today.
  upcoming,

  /// Every dose for today is done.
  done,

  /// No dose today — the frequency skips this day, or it is as-needed.
  inactive,
}

/// A medication plus today's progress, ready to render.
class MedicationStatus {
  const MedicationStatus({
    required this.medication,
    required this.state,
    required this.dosesToday,
    required this.takenToday,
    this.nextDose,
  });

  final Medication medication;
  final DoseState state;
  final List<Dose> dosesToday;
  final int takenToday;

  /// The dose being counted down to, today or on a later day.
  final DateTime? nextDose;

  int get totalToday => dosesToday.length;
  bool get isComplete => totalToday > 0 && takenToday == totalToday;
}

/// Turns the saved medications into today's ordered list.
///
/// Ordering follows what a person actually needs to see: anything missed,
/// then what is coming up soonest, then courses that do not apply today,
/// and finally everything already finished.
class MedicationSchedule {
  const MedicationSchedule();

  /// Rank for the top-level grouping. Lower sorts first.
  static int _rank(DoseState state) => switch (state) {
        DoseState.overdue => 0,
        DoseState.dueNow => 1,
        DoseState.upcoming => 2,
        DoseState.inactive => 3,
        DoseState.done => 4,
      };

  MedicationStatus statusFor(Medication medication, {DateTime? now}) {
    final moment = now ?? DateTime.now();
    final doses = medication.dosesOn(moment, now: moment);
    final taken = doses.where((d) => d.taken).length;

    final DoseState state;
    if (doses.isEmpty) {
      state = DoseState.inactive;
    } else if (taken == doses.length) {
      state = DoseState.done;
    } else if (doses.any((d) => d.isOverdue)) {
      state = DoseState.overdue;
    } else if (doses.any((d) => d.isDueNow)) {
      state = DoseState.dueNow;
    } else {
      state = DoseState.upcoming;
    }

    return MedicationStatus(
      medication: medication,
      state: state,
      dosesToday: doses,
      takenToday: taken,
      nextDose: medication.nextDoseAfter(moment),
    );
  }

  /// Today's list: missed first, then soonest due, finished at the bottom.
  ///
  /// Within the same group, the earlier dose comes first; medications with no
  /// upcoming dose fall back to alphabetical order so the list is stable.
  List<MedicationStatus> ordered(
    List<Medication> medications, {
    DateTime? now,
  }) {
    final moment = now ?? DateTime.now();
    final statuses = medications
        .where((m) => !m.hasEnded)
        .map((m) => statusFor(m, now: moment))
        .toList();

    statuses.sort((a, b) {
      final byState = _rank(a.state).compareTo(_rank(b.state));
      if (byState != 0) return byState;

      final aNext = _sortTime(a, moment);
      final bNext = _sortTime(b, moment);
      if (aNext != null && bNext != null) {
        final byTime = aNext.compareTo(bNext);
        if (byTime != 0) return byTime;
      } else if (aNext != null) {
        return -1;
      } else if (bNext != null) {
        return 1;
      }

      return a.medication.title.toLowerCase().compareTo(
            b.medication.title.toLowerCase(),
          );
    });

    return statuses;
  }

  /// Which moment decides the order inside a group.
  ///
  /// An overdue row sorts by the dose that was missed, so the longest
  /// outstanding one is at the top. Everything else sorts by what is next.
  static DateTime? _sortTime(MedicationStatus status, DateTime now) {
    if (status.state == DoseState.overdue) {
      final missed = status.dosesToday.where((d) => d.isOverdue).toList()
        ..sort((a, b) => a.at.compareTo(b.at));
      return missed.isEmpty ? status.nextDose : missed.first.at;
    }

    if (status.state == DoseState.dueNow) {
      final due = status.dosesToday.where((d) => d.isDueNow).toList()
        ..sort((a, b) => a.at.compareTo(b.at));
      return due.isEmpty ? status.nextDose : due.first.at;
    }

    if (status.state == DoseState.done) {
      // Finished rows read best in the order they were completed.
      final doses = [...status.dosesToday]..sort((a, b) => a.at.compareTo(b.at));
      return doses.isEmpty ? null : doses.last.at;
    }

    return status.nextDose;
  }

  /// Everything still to take today, across all medications, earliest first.
  List<Dose> remainingToday(List<Medication> medications, {DateTime? now}) {
    final moment = now ?? DateTime.now();
    final doses = <Dose>[];
    for (final medication in medications) {
      if (medication.hasEnded) continue;
      doses.addAll(
        medication.dosesOn(moment, now: moment).where((d) => !d.taken),
      );
    }
    doses.sort((a, b) => a.at.compareTo(b.at));
    return doses;
  }

  /// How many of today's doses are done, for the header summary.
  (int taken, int total) progressToday(
    List<Medication> medications, {
    DateTime? now,
  }) {
    final moment = now ?? DateTime.now();
    var taken = 0;
    var total = 0;
    for (final medication in medications) {
      if (medication.hasEnded) continue;
      final doses = medication.dosesOn(moment, now: moment);
      total += doses.length;
      taken += doses.where((d) => d.taken).length;
    }
    return (taken, total);
  }
}
