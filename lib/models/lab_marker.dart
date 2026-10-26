enum MarkerStatus { normal, low, high, unknown }

class LabMarker {
  const LabMarker({
    required this.id,
    required this.name,
    required this.unit,
    required this.status,
    this.value,
    this.resultText,
    this.referenceRange,
    this.information,
    this.description,
    this.recommendation,
    this.assayCode,
  });

  final String id;
  final String name;
  final double? value;
  final String? resultText;
  final String unit;
  final MarkerStatus status;
  final String? referenceRange;
  final String? information;
  final String? description;
  final String? recommendation;
  final String? assayCode;

  bool get isAbnormal =>
      status == MarkerStatus.low || status == MarkerStatus.high;

  String get displayResult {
    if (resultText != null && resultText!.trim().isNotEmpty) {
      return resultText!.trim();
    }
    if (value == null) return '—';
    final v = value!;
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(v < 10 ? 2 : 1);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'value': value,
        'resultText': resultText,
        'unit': unit,
        'status': status.name,
        'referenceRange': referenceRange,
        'information': information,
        'description': description,
        'recommendation': recommendation,
        'assayCode': assayCode,
      };

  factory LabMarker.fromJson(Map<String, dynamic> json) => LabMarker(
        id: json['id'] as String,
        name: json['name'] as String,
        value: json['value'] == null ? null : (json['value'] as num).toDouble(),
        resultText: json['resultText'] as String?,
        unit: json['unit'] as String? ?? '',
        status: MarkerStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => MarkerStatus.unknown,
        ),
        referenceRange: json['referenceRange'] as String?,
        information: json['information'] as String?,
        description: json['description'] as String?,
        recommendation: json['recommendation'] as String?,
        assayCode: json['assayCode'] as String?,
      );
}
