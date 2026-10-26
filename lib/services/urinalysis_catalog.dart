import '../models/lab_marker.dart';

class UrineTestDef {
  const UrineTestDef({
    required this.id,
    required this.name,
    required this.patterns,
    required this.information,
    required this.description,
    required this.normalSuggestion,
    required this.abnormalSuggestion,
    this.unit = '',
    this.referenceRange,
    this.numericLow,
    this.numericHigh,
    this.expectNegative = false,
  });

  final String id;
  final String name;
  final List<RegExp> patterns;
  final String information;
  final String description;
  final String normalSuggestion;
  final String abnormalSuggestion;
  final String unit;
  final String? referenceRange;
  final double? numericLow;
  final double? numericHigh;
  final bool expectNegative;
}

class UrinalysisCatalog {
  static final List<UrineTestDef> all = [
    UrineTestDef(
      id: 'urine_color',
      name: 'Urine Color',
      patterns: [
        RegExp(r'Color\s*/', caseSensitive: false),
        RegExp(r'\bColor\b', caseSensitive: false),
      ],
      information:
          'Urine color is a basic visual check of hydration and urine composition.',
      description:
          'Light yellow is typically normal. Very dark, red, or unusual colors may need clinical review.',
      normalSuggestion:
          'Keep good hydration unless your clinician advises otherwise.',
      abnormalSuggestion:
          'Unusual urine color can relate to dehydration, food, medication, or blood — ask your clinician if it persists.',
      referenceRange: 'Light yellow',
    ),
    UrineTestDef(
      id: 'urine_transparency',
      name: 'Transparency',
      patterns: [
        RegExp(r'Transpar(?:e)?ncy|Transparity', caseSensitive: false),
      ],
      information: 'Shows whether urine looks clear or cloudy.',
      description:
          'Clear/transparent urine is common. Cloudiness can appear with cells, crystals, or infection.',
      normalSuggestion: 'No special action if you feel well.',
      abnormalSuggestion:
          'Cloudy urine with symptoms (pain, urgency, fever) should be reviewed by a clinician.',
      referenceRange: 'Transparent / clear',
    ),
    UrineTestDef(
      id: 'urine_sg',
      name: 'Specific Gravity',
      patterns: [
        RegExp(r'Specific\s*gravity', caseSensitive: false),
      ],
      information:
          'Specific gravity reflects urine concentration and hydration status.',
      description:
          'Higher values usually mean more concentrated urine; lower values mean more dilute urine.',
      normalSuggestion: 'Maintain regular fluid intake through the day.',
      abnormalSuggestion:
          'Very high or low specific gravity may need clinical context with other kidney/urine tests.',
      referenceRange: '1.005–1.030',
      numericLow: 1.005,
      numericHigh: 1.030,
    ),
    UrineTestDef(
      id: 'urine_ph',
      name: 'Urine pH',
      patterns: [
        RegExp(r'\bpH\s*/', caseSensitive: false),
        RegExp(r'\bpH\b', caseSensitive: false),
      ],
      information: 'Urine pH shows how acidic or alkaline the urine is.',
      description: 'Diet, infection, and kidney function can influence urine pH.',
      normalSuggestion: 'Usually no action needed when pH is in range.',
      abnormalSuggestion:
          'Out-of-range pH is interpreted with symptoms and other urine findings by your clinician.',
      referenceRange: '4.5–8.5',
      numericLow: 4.5,
      numericHigh: 8.5,
    ),
    UrineTestDef(
      id: 'urine_leukocytes',
      name: 'Leukocytes (urine)',
      patterns: [RegExp(r'Leukocytes?', caseSensitive: false)],
      information:
          'Leukocytes in urine can suggest inflammation or urinary tract infection.',
      description: 'A negative result is expected in an uncomplicated strip test.',
      normalSuggestion: 'No infection signal from this marker alone.',
      abnormalSuggestion:
          'Positive leukocytes with urinary symptoms should be checked by a clinician.',
      unit: 'cells/uL',
      referenceRange: 'Negative',
      expectNegative: true,
    ),
    UrineTestDef(
      id: 'urine_nitrites',
      name: 'Nitrites',
      patterns: [RegExp(r'Nitrites?', caseSensitive: false)],
      information:
          'Nitrites can appear when certain bacteria are present in urine.',
      description:
          'Negative nitrites lower the chance of bacterial UTI, but do not fully exclude it.',
      normalSuggestion: 'No nitrite-related infection signal.',
      abnormalSuggestion:
          'Positive nitrites often need clinical evaluation for possible UTI.',
      referenceRange: 'Negative',
      expectNegative: true,
    ),
    UrineTestDef(
      id: 'urine_protein',
      name: 'Protein (urine)',
      patterns: [RegExp(r'Protein\s*/', caseSensitive: false)],
      information:
          'Protein in urine can relate to kidney stress, fever, exercise, or other conditions.',
      description: 'A negative strip result is the usual expected finding.',
      normalSuggestion: 'No protein detected on this strip test.',
      abnormalSuggestion:
          'Protein in urine may need follow-up, especially if it repeats.',
      unit: 'g/L',
      referenceRange: 'Negative',
      expectNegative: true,
    ),
    UrineTestDef(
      id: 'urine_glucose',
      name: 'Glucose (urine)',
      patterns: [RegExp(r'Glucose\s*/', caseSensitive: false)],
      information:
          'Urine glucose is usually negative; sugar in urine can appear with high blood glucose.',
      description:
          'This is a urine strip result, not the same as a blood glucose lab value.',
      normalSuggestion: 'No glucose detected in urine.',
      abnormalSuggestion:
          'Glucose in urine should be discussed with your clinician, especially with diabetes risk.',
      unit: 'mmol/L',
      referenceRange: 'Negative',
      expectNegative: true,
    ),
    UrineTestDef(
      id: 'urine_ketones',
      name: 'Ketones',
      patterns: [RegExp(r'Ketones?', caseSensitive: false)],
      information:
          'Ketones can appear with fasting, low-carb intake, illness, or uncontrolled diabetes.',
      description: 'Negative ketones are the usual strip finding.',
      normalSuggestion: 'No ketones detected.',
      abnormalSuggestion:
          'Positive ketones with symptoms (nausea, confusion, high sugar) need urgent clinical advice.',
      unit: 'mmol/L',
      referenceRange: 'Negative',
      expectNegative: true,
    ),
    UrineTestDef(
      id: 'urine_urobilinogen',
      name: 'Urobilinogen',
      patterns: [RegExp(r'Urobilinogen', caseSensitive: false)],
      information:
          'Urobilinogen relates to bile pigment processing and liver/bilirubin pathways.',
      description:
          'Negative or very low values are commonly reported as normal on strip tests.',
      normalSuggestion: 'No urobilinogen concern on this strip.',
      abnormalSuggestion:
          'Elevated urobilinogen may need clinical review with liver-related tests.',
      unit: 'µmol/L',
      referenceRange: '≤ 16.0 µmol/L / Negative',
      expectNegative: true,
    ),
    UrineTestDef(
      id: 'urine_bilirubin',
      name: 'Bilirubin (urine)',
      patterns: [RegExp(r'Bilirubin\s*/', caseSensitive: false)],
      information:
          'Bilirubin in urine can be linked to liver or bile duct issues.',
      description: 'Negative is the expected strip result.',
      normalSuggestion: 'No bilirubin detected in urine.',
      abnormalSuggestion:
          'Positive urine bilirubin should be reviewed by a clinician.',
      unit: 'µmol/L',
      referenceRange: 'Negative',
      expectNegative: true,
    ),
    UrineTestDef(
      id: 'urine_erythrocytes',
      name: 'Erythrocytes (urine)',
      patterns: [RegExp(r'Erythrocytes?', caseSensitive: false)],
      information:
          'Erythrocytes are red blood cells; their presence in urine needs context.',
      description:
          'Negative is expected. Blood in urine can come from infection, stones, or other causes.',
      normalSuggestion: 'No blood cells detected on this strip.',
      abnormalSuggestion:
          'Blood in urine should be checked by a clinician, especially if it repeats or symptoms appear.',
      unit: 'cells/uL',
      referenceRange: 'Negative',
      expectNegative: true,
    ),
  ];
}

class UrinalysisParser {
  bool isUrinalysis(String text) {
    final lower = text.toLowerCase();
    return lower.contains('urinalysis') ||
        lower.contains('strip test') ||
        lower.contains('urine');
  }

  List<LabMarker> parse(String text) {
    if (!isUrinalysis(text)) return const [];

    final markers = <LabMarker>[];
    final seen = <String>{};

    for (final def in UrinalysisCatalog.all) {
      if (seen.contains(def.id)) continue;
      for (final pattern in def.patterns) {
        final match = pattern.firstMatch(text);
        if (match == null) continue;

        final windowEnd = (match.end + 140).clamp(0, text.length);
        final window = text.substring(match.start, windowEnd);
        final marker = _parseWindow(def, window);
        if (marker == null) continue;
        markers.add(marker);
        seen.add(def.id);
        break;
      }
    }

    return markers;
  }

  LabMarker? _parseWindow(UrineTestDef def, String window) {
    if (def.numericLow != null && def.numericHigh != null) {
      final value = _extractNumericResult(def, window);
      if (value == null) return null;
      final status = value < def.numericLow! || value > def.numericHigh!
          ? MarkerStatus.high
          : MarkerStatus.normal;
      return LabMarker(
        id: def.id,
        name: def.name,
        value: value,
        resultText: value.toString(),
        unit: def.unit,
        status: status,
        referenceRange: def.referenceRange,
        information: def.information,
        description: def.description,
        recommendation: status == MarkerStatus.normal
            ? def.normalSuggestion
            : def.abnormalSuggestion,
      );
    }

    final qualitative = _extractQualitative(window);
    if (qualitative == null) return null;

    final status = _statusForQualitative(def, qualitative.normalized);
    return LabMarker(
      id: def.id,
      name: def.name,
      resultText: qualitative.display,
      unit: def.unit,
      status: status,
      referenceRange: def.referenceRange,
      information: def.information,
      description: def.description,
      recommendation: status == MarkerStatus.normal
          ? def.normalSuggestion
          : def.abnormalSuggestion,
    );
  }

  double? _extractNumericResult(UrineTestDef def, String window) {
    var cleaned = window;
    cleaned = cleaned.replaceAll(
      RegExp(r'\d{1,3}(?:[.,]\d{1,4})?\s*[-–—]\s*\d{1,3}(?:[.,]\d{1,4})?'),
      ' ',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'[<>]=?\s*\d{1,3}(?:[.,]\d{1,4})?'),
      ' ',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\b\d{1,2}/\d{1,2}/\d{2,4}\b'), ' ');
    cleaned = cleaned.replaceAll(
      RegExp(r'\by\.?o\.?', caseSensitive: false),
      ' ',
    );

    final numbers = RegExp(r'(\d{1,2}(?:[.,]\d{1,4})?)')
        .allMatches(cleaned)
        .map((m) => double.tryParse(m.group(1)!.replaceAll(',', '.')))
        .whereType<double>()
        .toList();
    if (numbers.isEmpty) return null;

    if (def.id == 'urine_sg') {
      final sg = numbers.where((n) => n >= 1.0 && n <= 1.05).toList();
      if (sg.isNotEmpty) return sg.last;
    }
    if (def.id == 'urine_ph') {
      final ph = numbers.where((n) => n >= 4 && n <= 9).toList();
      if (ph.isNotEmpty) return ph.last;
    }
    return numbers.last;
  }

  _QualResult? _extractQualitative(String window) {
    final lower = window.toLowerCase();

    if (RegExp(r'\bnegative\b', caseSensitive: false).hasMatch(lower)) {
      return const _QualResult(display: 'Negative', normalized: 'negative');
    }
    if (RegExp(r'\b(?:positive|trace)\b', caseSensitive: false).hasMatch(lower)) {
      final display =
          RegExp(r'\btrace\b', caseSensitive: false).hasMatch(lower)
              ? 'Trace'
              : 'Positive';
      return _QualResult(display: display, normalized: 'positive');
    }
    if (RegExp(r'light\s*yellow', caseSensitive: false).hasMatch(lower)) {
      return const _QualResult(
        display: 'Light yellow',
        normalized: 'light_yellow',
      );
    }
    if (RegExp(r'\btransparent\b', caseSensitive: false).hasMatch(lower)) {
      return const _QualResult(
        display: 'Transparent',
        normalized: 'transparent',
      );
    }
    if (RegExp(r'\bcloudy\b', caseSensitive: false).hasMatch(lower)) {
      return const _QualResult(display: 'Cloudy', normalized: 'cloudy');
    }
    return null;
  }

  MarkerStatus _statusForQualitative(UrineTestDef def, String normalized) {
    if (def.expectNegative) {
      if (normalized.contains('negative')) return MarkerStatus.normal;
      if (normalized.contains('positive') || normalized.contains('trace')) {
        return MarkerStatus.high;
      }
    }
    if (def.id == 'urine_color') {
      return normalized.contains('yellow')
          ? MarkerStatus.normal
          : MarkerStatus.unknown;
    }
    if (def.id == 'urine_transparency') {
      if (normalized.contains('transparent') || normalized.contains('clear')) {
        return MarkerStatus.normal;
      }
      if (normalized.contains('cloudy')) return MarkerStatus.high;
    }
    return MarkerStatus.unknown;
  }
}

class _QualResult {
  const _QualResult({required this.display, required this.normalized});
  final String display;
  final String normalized;
}
