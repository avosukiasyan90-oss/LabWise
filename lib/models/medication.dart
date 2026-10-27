import 'package:flutter/material.dart';

/// How often a course repeats.
enum MedicationFrequency {
  daily,
  everyOtherDay,
  weekly,

  /// No schedule — taken only when needed, so it is never reminded about.
  asNeeded;

  static MedicationFrequency fromName(String? name) =>
      MedicationFrequency.values.firstWhere(
        (f) => f.name == name,
        orElse: () => MedicationFrequency.daily,
      );

  /// Days between doses. Null for [asNeeded], which has no cadence.
  int? get intervalDays => switch (this) {
        MedicationFrequency.daily => 1,
        MedicationFrequency.everyOtherDay => 2,
        MedicationFrequency.weekly => 7,
        MedicationFrequency.asNeeded => null,
      };
}

/// A time of day stored without a date, so it survives JSON round-trips.
class DoseTime implements Comparable<DoseTime> {
  const DoseTime({required this.hour, required this.minute});

  final int hour;
  final int minute;

  factory DoseTime.fromTimeOfDay(TimeOfDay time) =>
      DoseTime(hour: time.hour, minute: time.minute);

  TimeOfDay get asTimeOfDay => TimeOfDay(hour: hour, minute: minute);

  int get minutesOfDay => hour * 60 + minute;

  /// This time on a given day.
  DateTime on(DateTime day) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  @override
  int compareTo(DoseTime other) =>
      minutesOfDay.compareTo(other.minutesOfDay);

  @override
  bool operator ==(Object other) =>
      other is DoseTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  String get key =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};

  factory DoseTime.fromJson(Map<String, dynamic> json) => DoseTime(
        hour: (json['hour'] as num?)?.toInt() ?? 9,
        minute: (json['minute'] as num?)?.toInt() ?? 0,
      );
}

/// One scheduled dose on a specific day.
class Dose {
  const Dose({
    required this.medication,
    required this.at,
    required this.taken,
    required this.asOf,
  });

  final Medication medication;
  final DateTime at;
  final bool taken;

  /// The moment this dose was evaluated against, so "overdue" stays
  /// consistent with whatever time the caller is reasoning about.
  final DateTime asOf;

  /// How long after its time a dose is still simply "due" rather than missed.
  ///
  /// Without this a dose flips to missed the second its time passes, which is
  /// both alarming and wrong — nobody takes a tablet at the exact minute.
  /// Ten minutes is long enough to walk to the kitchen, short enough that a
  /// genuinely forgotten dose is flagged while the day can still be fixed.
  static const Duration grace = Duration(minutes: 10);

  DateTime get _missedAfter => at.add(grace);

  /// Its time has come but the grace window has not run out.
  bool get isDueNow =>
      !taken && !at.isAfter(asOf) && asOf.isBefore(_missedAfter);

  /// Past the grace window and still not taken.
  bool get isOverdue => !taken && !asOf.isBefore(_missedAfter);

  String get key => Medication.doseKey(at);
}

/// A medicine or supplement the user is taking.
class Medication {
  const Medication({
    required this.id,
    required this.title,
    required this.times,
    required this.startDate,
    this.count = 1,
    this.frequency = MedicationFrequency.daily,
    this.notes,
    this.endDate,
    this.takenKeys = const {},
    this.createdAt,
  });

  final String id;
  final String title;

  /// Tablets, drops, or millilitres per dose — whatever the label says.
  final int count;

  /// One or more reminder times per active day.
  final List<DoseTime> times;

  final MedicationFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime? createdAt;

  /// Doses already taken, keyed by exact timestamp.
  final Set<String> takenKeys;

  /// Stable key for a dose at a given moment.
  static String doseKey(DateTime at) =>
      '${at.year}-${_two(at.month)}-${_two(at.day)}T'
      '${_two(at.hour)}:${_two(at.minute)}';

  static String _two(int value) => value.toString().padLeft(2, '0');

  bool get isScheduled => frequency != MedicationFrequency.asNeeded;

  bool get hasEnded =>
      endDate != null && DateTime.now().isAfter(_endOfDay(endDate!));

  static DateTime _endOfDay(DateTime day) =>
      DateTime(day.year, day.month, day.day, 23, 59, 59);

  static DateTime _dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Whether a dose falls on [day] at all, given the frequency and dates.
  bool fallsOn(DateTime day) {
    if (!isScheduled) return false;

    final target = _dayOf(day);
    final start = _dayOf(startDate);
    if (target.isBefore(start)) return false;
    if (endDate != null && target.isAfter(_dayOf(endDate!))) return false;

    final interval = frequency.intervalDays!;
    final elapsed = target.difference(start).inDays;
    return elapsed % interval == 0;
  }

  bool isTakenAt(DateTime at) => takenKeys.contains(doseKey(at));

  /// Every dose due on [day], earliest first.
  ///
  /// [now] decides which of them count as overdue; it defaults to the clock
  /// but is injectable so schedules can be reasoned about for any moment.
  List<Dose> dosesOn(DateTime day, {DateTime? now}) {
    if (!fallsOn(day)) return const [];
    final asOf = now ?? DateTime.now();
    final sorted = [...times]..sort();
    return sorted.map((time) {
      final at = time.on(day);
      return Dose(
        medication: this,
        at: at,
        taken: isTakenAt(at),
        asOf: asOf,
      );
    }).toList();
  }

  /// The next dose still to come, searching up to [withinDays] ahead.
  DateTime? nextDoseAfter(DateTime from, {int withinDays = 14}) {
    if (!isScheduled || hasEnded) return null;
    final sorted = [...times]..sort();

    for (var offset = 0; offset <= withinDays; offset++) {
      final day = _dayOf(from).add(Duration(days: offset));
      if (!fallsOn(day)) continue;
      for (final time in sorted) {
        final at = time.on(day);
        if (at.isAfter(from) && !isTakenAt(at)) return at;
      }
    }
    return null;
  }

  Medication copyWith({
    String? title,
    int? count,
    List<DoseTime>? times,
    MedicationFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    String? notes,
    Set<String>? takenKeys,
  }) =>
      Medication(
        id: id,
        title: title ?? this.title,
        count: count ?? this.count,
        times: times ?? this.times,
        frequency: frequency ?? this.frequency,
        startDate: startDate ?? this.startDate,
        endDate: clearEndDate ? null : (endDate ?? this.endDate),
        notes: notes ?? this.notes,
        takenKeys: takenKeys ?? this.takenKeys,
        createdAt: createdAt,
      );

  Medication markTaken(DateTime at, {required bool taken}) {
    final next = {...takenKeys};
    if (taken) {
      next.add(doseKey(at));
    } else {
      next.remove(doseKey(at));
    }
    return copyWith(takenKeys: next);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'count': count,
        'times': times.map((t) => t.toJson()).toList(),
        'frequency': frequency.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'notes': notes,
        'takenKeys': takenKeys.toList(),
        'createdAt': createdAt?.toIso8601String(),
      };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        count: (json['count'] as num?)?.toInt() ?? 1,
        times: (json['times'] as List<dynamic>? ?? [])
            .map((e) => DoseTime.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        frequency: MedicationFrequency.fromName(json['frequency'] as String?),
        startDate: DateTime.parse(
          json['startDate'] as String? ?? DateTime.now().toIso8601String(),
        ),
        endDate: json['endDate'] == null
            ? null
            : DateTime.parse(json['endDate'] as String),
        notes: json['notes'] as String?,
        takenKeys: (json['takenKeys'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toSet(),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
      );
}
