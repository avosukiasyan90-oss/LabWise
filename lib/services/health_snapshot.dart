import '../models/medical_report.dart';
import '../models/user_profile.dart';

/// Overall read on how things are going right now.
enum HealthTone {
  /// Nothing flagged and the profile sits in a healthy range.
  good,

  /// Something is slightly off — a couple of markers, or BMI outside range.
  watch,

  /// Several markers need attention, or BMI is well outside range.
  attention,

  /// Not enough information to say anything yet.
  unknown,
}

enum BmiBand { under, healthy, above, wellAbove }

/// A one-glance summary of the user's position, combining the body details
/// they entered with whatever their most recent report found.
///
/// Pure data: no formatting, so the widget owns every translated string.
class HealthSnapshot {
  const HealthSnapshot({
    required this.tone,
    required this.flagged,
    required this.tracked,
    required this.reportCount,
    this.bmi,
    this.band,
    this.lastReportAt,
    this.missingProfileFields = const [],
  });

  final HealthTone tone;

  /// Markers outside their range in the most recent report.
  final int flagged;

  /// Markers read in the most recent report.
  final int tracked;

  final int reportCount;
  final double? bmi;
  final BmiBand? band;
  final DateTime? lastReportAt;

  /// Which of weight, height, and age are still missing.
  final List<String> missingProfileFields;

  bool get hasReport => reportCount > 0;
  bool get hasBmi => bmi != null;
  bool get isEmpty => tone == HealthTone.unknown;

  static BmiBand bandFor(double bmi) {
    if (bmi < 18.5) return BmiBand.under;
    if (bmi < 25) return BmiBand.healthy;
    if (bmi < 30) return BmiBand.above;
    return BmiBand.wellAbove;
  }

  /// Builds the snapshot from the profile and the reports already uploaded.
  ///
  /// The newest report is the one that counts — older ones describe a body
  /// that has since changed.
  factory HealthSnapshot.of({
    required UserProfile profile,
    required List<MedicalReport> reports,
  }) {
    final missing = <String>[
      if (profile.weightKg == null) 'weight',
      if (profile.heightCm == null) 'height',
      if (profile.age == null) 'age',
    ];

    final bmi = profile.bmi;
    final band = bmi == null ? null : bandFor(bmi);

    final sorted = [...reports]
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    final latest = sorted.isEmpty ? null : sorted.first;

    final flagged = latest?.abnormalCount ?? 0;
    final tracked = latest?.markers.length ?? 0;

    return HealthSnapshot(
      tone: _toneFor(band: band, flagged: flagged, hasReport: latest != null),
      flagged: flagged,
      tracked: tracked,
      reportCount: reports.length,
      bmi: bmi,
      band: band,
      lastReportAt: latest?.uploadedAt,
      missingProfileFields: missing,
    );
  }

  /// Lab findings outrank body measurements: a flagged marker is a concrete
  /// result, while BMI is only an estimate from two numbers.
  static HealthTone _toneFor({
    required BmiBand? band,
    required int flagged,
    required bool hasReport,
  }) {
    if (band == null && !hasReport) return HealthTone.unknown;

    if (flagged >= 3) return HealthTone.attention;
    if (band == BmiBand.wellAbove) return HealthTone.attention;

    if (flagged > 0) return HealthTone.watch;
    if (band == BmiBand.above || band == BmiBand.under) return HealthTone.watch;

    return HealthTone.good;
  }
}
