import 'lab_marker.dart';
import 'medical_report.dart';

/// Which way a value moved relative to its healthy range.
enum TrendDirection { improved, worsened, steady }

/// One marker as it stood in a report that a newer upload replaced.
///
/// Only the fields needed to draw a comparison are kept, so superseding a
/// report does not double the storage it takes.
class MarkerSnapshot {
  const MarkerSnapshot({
    required this.id,
    required this.status,
    this.value,
    this.resultText,
  });

  final String id;
  final MarkerStatus status;
  final double? value;
  final String? resultText;

  bool get isAbnormal =>
      status == MarkerStatus.low || status == MarkerStatus.high;

  String get display {
    final text = resultText?.trim();
    if (text != null && text.isNotEmpty) return text;
    final v = value;
    if (v == null) return '—';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(v < 10 ? 2 : 1);
  }

  factory MarkerSnapshot.of(LabMarker marker) => MarkerSnapshot(
        id: marker.id,
        status: marker.status,
        value: marker.value,
        resultText: marker.resultText,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.name,
        'value': value,
        'resultText': resultText,
      };

  factory MarkerSnapshot.fromJson(Map<String, dynamic> json) => MarkerSnapshot(
        id: json['id'] as String,
        status: MarkerStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => MarkerStatus.unknown,
        ),
        value: json['value'] == null ? null : (json['value'] as num).toDouble(),
        resultText: json['resultText'] as String?,
      );
}

/// The report a newer upload of the same panel replaced in History.
class ReportSnapshot {
  const ReportSnapshot({
    required this.id,
    required this.fileName,
    required this.uploadedAt,
    required this.markers,
    this.sampleDate,
  });

  final String id;
  final String fileName;
  final DateTime uploadedAt;
  final List<MarkerSnapshot> markers;
  final String? sampleDate;

  factory ReportSnapshot.of(MedicalReport report) => ReportSnapshot(
        id: report.id,
        fileName: report.fileName,
        uploadedAt: report.uploadedAt,
        sampleDate: report.sampleDate,
        markers: report.markers.map(MarkerSnapshot.of).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'uploadedAt': uploadedAt.toIso8601String(),
        'sampleDate': sampleDate,
        'markers': markers.map((m) => m.toJson()).toList(),
      };

  factory ReportSnapshot.fromJson(Map<String, dynamic> json) => ReportSnapshot(
        id: json['id'] as String? ?? '',
        fileName: json['fileName'] as String? ?? '',
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        sampleDate: json['sampleDate'] as String?,
        markers: (json['markers'] as List<dynamic>? ?? [])
            .map((e) => MarkerSnapshot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A single marker measured in both the old and the new report.
class MarkerDelta {
  const MarkerDelta({
    required this.current,
    required this.previous,
    required this.direction,
  });

  final LabMarker current;
  final MarkerSnapshot previous;
  final TrendDirection direction;

  String get name => current.name;
  String get unit => current.unit;

  /// Null when either side is a word rather than a number.
  double? get change {
    final a = previous.value;
    final b = current.value;
    if (a == null || b == null) return null;
    return b - a;
  }

  /// Null when there is no numeric change or the old value was zero.
  double? get percentChange {
    final a = previous.value;
    final delta = change;
    if (a == null || a == 0 || delta == null) return null;
    return delta / a.abs() * 100;
  }

  /// True when the value crossed back into its reference range.
  bool get enteredRange =>
      previous.isAbnormal && current.status == MarkerStatus.normal;

  /// True when the value fell out of its reference range.
  bool get leftRange =>
      !previous.isAbnormal &&
      previous.status != MarkerStatus.unknown &&
      current.isAbnormal;
}

/// How a report compares with the one it replaced.
///
/// Scores are computed over the markers present in *both* reports, so a panel
/// that measured extra values the second time does not skew the comparison.
class ReportComparison {
  const ReportComparison({
    required this.previous,
    required this.current,
    required this.deltas,
  });

  final ReportSnapshot previous;
  final MedicalReport current;
  final List<MarkerDelta> deltas;

  List<MarkerDelta> get improved =>
      deltas.where((d) => d.direction == TrendDirection.improved).toList();

  List<MarkerDelta> get worsened =>
      deltas.where((d) => d.direction == TrendDirection.worsened).toList();

  List<MarkerDelta> get steady =>
      deltas.where((d) => d.direction == TrendDirection.steady).toList();

  int get comparedCount => deltas.length;

  int get previousInRange => deltas
      .where((d) => d.previous.status == MarkerStatus.normal)
      .length;

  int get currentInRange =>
      deltas.where((d) => d.current.status == MarkerStatus.normal).length;

  /// Share of the shared markers that sat inside their range, 0–100.
  double? get previousScore =>
      deltas.isEmpty ? null : previousInRange / deltas.length * 100;

  double? get currentScore =>
      deltas.isEmpty ? null : currentInRange / deltas.length * 100;

  /// Change in that share, in percentage points.
  double? get scoreChange {
    final before = previousScore;
    final after = currentScore;
    if (before == null || after == null) return null;
    return after - before;
  }

  TrendDirection get overall {
    if (improved.length > worsened.length) return TrendDirection.improved;
    if (worsened.length > improved.length) return TrendDirection.worsened;
    return TrendDirection.steady;
  }

  /// Deltas worth showing first: the ones that actually moved.
  List<MarkerDelta> get notable {
    final moved = deltas
        .where((d) => d.direction != TrendDirection.steady)
        .toList();
    return moved.isEmpty ? deltas : moved;
  }

  bool get isEmpty => deltas.isEmpty;
}
