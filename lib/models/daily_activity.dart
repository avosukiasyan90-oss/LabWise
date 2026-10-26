import 'package:flutter/material.dart';

/// The kinds of movement the calendar shows separately.
enum ActivityKind {
  walking,
  running,
  cycling,
  other;

  IconData get icon => switch (this) {
        ActivityKind.walking => Icons.directions_walk_rounded,
        ActivityKind.running => Icons.directions_run_rounded,
        ActivityKind.cycling => Icons.directions_bike_rounded,
        ActivityKind.other => Icons.fitness_center_rounded,
      };

  static ActivityKind fromName(String? name) => ActivityKind.values.firstWhere(
        (k) => k.name == name,
        orElse: () => ActivityKind.other,
      );
}

/// One recorded workout, as Apple Health or Health Connect reported it.
class ActivitySession {
  const ActivitySession({
    required this.kind,
    required this.start,
    required this.end,
    this.km,
    this.kcal,
  });

  final ActivityKind kind;
  final DateTime start;
  final DateTime end;
  final double? km;
  final int? kcal;

  Duration get duration => end.difference(start);

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'km': km,
        'kcal': kcal,
      };

  factory ActivitySession.fromJson(Map<String, dynamic> json) =>
      ActivitySession(
        kind: ActivityKind.fromName(json['kind'] as String?),
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        km: (json['km'] as num?)?.toDouble(),
        kcal: (json['kcal'] as num?)?.toInt(),
      );
}

/// Everything the calendar needs for a single day.
class DailyActivity {
  const DailyActivity({
    required this.day,
    this.steps = 0,
    this.walkRunKm = 0,
    this.cycleKm = 0,
    this.activeMinutes = 0,
    this.activeKcal = 0,
    this.sessions = const [],
  });

  /// Midnight, local time, of the day described.
  final DateTime day;
  final int steps;
  final double walkRunKm;
  final double cycleKm;
  final int activeMinutes;
  final int activeKcal;
  final List<ActivitySession> sessions;

  double get totalKm => walkRunKm + cycleKm;

  bool get isEmpty =>
      steps == 0 &&
      walkRunKm == 0 &&
      cycleKm == 0 &&
      activeMinutes == 0 &&
      activeKcal == 0 &&
      sessions.isEmpty;

  bool get hasMovement => !isEmpty;

  /// Normalises any timestamp to the midnight key used throughout.
  static DateTime dayKey(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DailyActivity copyWith({
    int? steps,
    double? walkRunKm,
    double? cycleKm,
    int? activeMinutes,
    int? activeKcal,
    List<ActivitySession>? sessions,
  }) =>
      DailyActivity(
        day: day,
        steps: steps ?? this.steps,
        walkRunKm: walkRunKm ?? this.walkRunKm,
        cycleKm: cycleKm ?? this.cycleKm,
        activeMinutes: activeMinutes ?? this.activeMinutes,
        activeKcal: activeKcal ?? this.activeKcal,
        sessions: sessions ?? this.sessions,
      );

  Map<String, dynamic> toJson() => {
        'day': day.toIso8601String(),
        'steps': steps,
        'walkRunKm': walkRunKm,
        'cycleKm': cycleKm,
        'activeMinutes': activeMinutes,
        'activeKcal': activeKcal,
        'sessions': sessions.map((s) => s.toJson()).toList(),
      };

  factory DailyActivity.fromJson(Map<String, dynamic> json) => DailyActivity(
        day: DailyActivity.dayKey(DateTime.parse(json['day'] as String)),
        steps: (json['steps'] as num?)?.toInt() ?? 0,
        walkRunKm: (json['walkRunKm'] as num?)?.toDouble() ?? 0,
        cycleKm: (json['cycleKm'] as num?)?.toDouble() ?? 0,
        activeMinutes: (json['activeMinutes'] as num?)?.toInt() ?? 0,
        activeKcal: (json['activeKcal'] as num?)?.toInt() ?? 0,
        sessions: (json['sessions'] as List<dynamic>? ?? [])
            .map((e) => ActivitySession.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
