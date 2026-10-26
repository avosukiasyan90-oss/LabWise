import '../models/lab_marker.dart';
import '../models/medical_report.dart';
import '../models/report_category.dart';
import '../models/report_comparison.dart';

/// Decides when a new upload is a repeat of a test already in History, and
/// works out which values got better or worse since then.
///
/// All of this is plain arithmetic against each marker's reference range — it
/// runs on-device and needs no network.
class ReportComparator {
  const ReportComparator();

  /// How much of the smaller panel must overlap for two reports to count as
  /// the same test. Labs rename or drop the odd marker between visits, so an
  /// exact match would almost never fire.
  static const double overlapThreshold = 0.6;

  /// The most recent report in [history] that looks like a repeat of [report].
  ///
  /// Returns null when this is the first test of its kind.
  MedicalReport? findPreviousInSeries(
    MedicalReport report,
    List<MedicalReport> history,
  ) {
    final ids = _comparableIds(report);
    if (ids.isEmpty) return null;

    final category = categoryOf(report);
    final candidates = history
        .where((other) => other.id != report.id)
        .where((other) => categoryOf(other) == category)
        .where((other) => _overlap(ids, _comparableIds(other)) >= overlapThreshold)
        .toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    return candidates.isEmpty ? null : candidates.first;
  }

  /// Builds the comparison a report carries from the upload it replaced.
  ///
  /// Returns null when the report is not a repeat or shares no markers with
  /// the one it superseded.
  ReportComparison? compare(MedicalReport report) {
    final previous = report.previous;
    if (previous == null) return null;

    final before = {for (final m in previous.markers) m.id: m};
    final deltas = <MarkerDelta>[];

    for (final marker in report.markers) {
      final was = before[marker.id];
      if (was == null) continue;
      deltas.add(
        MarkerDelta(
          current: marker,
          previous: was,
          direction: directionFor(previous: was, current: marker),
        ),
      );
    }

    if (deltas.isEmpty) return null;
    return ReportComparison(
      previous: previous,
      current: report,
      deltas: deltas,
    );
  }

  /// Whether a value moved toward its reference range or away from it.
  static TrendDirection directionFor({
    required MarkerSnapshot previous,
    required LabMarker current,
  }) {
    final was = previous.status;
    final now = current.status;

    // A value the catalogue could not grade on either visit gives us nothing
    // honest to claim about direction.
    if (was == MarkerStatus.unknown || now == MarkerStatus.unknown) {
      return TrendDirection.steady;
    }

    final wasOut = previous.isAbnormal;
    final isOut = current.isAbnormal;

    if (wasOut && !isOut) return TrendDirection.improved;
    if (!wasOut && isOut) return TrendDirection.worsened;
    if (!wasOut && !isOut) return TrendDirection.steady;

    // Out of range both times. Overshooting the range entirely — a low value
    // that is now high, or the reverse — is not progress.
    if (was != now) return TrendDirection.worsened;

    final before = previous.value;
    final after = current.value;
    if (before == null || after == null || before == after) {
      return TrendDirection.steady;
    }

    // Too high: smaller is closer to the range. Too low: larger is.
    final movedToward = was == MarkerStatus.high ? after < before : after > before;
    return movedToward ? TrendDirection.improved : TrendDirection.worsened;
  }

  Set<String> _comparableIds(MedicalReport report) =>
      report.markers.map((m) => m.id).toSet();

  /// Overlap relative to the smaller panel, so a short follow-up test still
  /// matches the full panel it came from.
  double _overlap(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final shared = a.intersection(b).length;
    final smaller = a.length < b.length ? a.length : b.length;
    return shared / smaller;
  }
}
