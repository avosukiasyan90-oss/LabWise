import '../models/lab_marker.dart';

/// Reads Helicobacter pylori urea breath tests ("Helik test" / Heliforce
/// Urea ¹³C), where the result is a tick next to Negative or Positive rather
/// than a number.
class HelicobacterParser {
  static final _testPattern = RegExp(
    r'ՀԵԼԻԿ\s*ԹԵՍՏ|Հելիկ\s*[Թթ]եստ|Heliforce|Helicobacter|Хеликобактер|'
    r'H\.?\s*pylori|Urea\s*Breath|ՈՒՐԵԱԶ',
    caseSensitive: false,
  );

  static final _conclusionPattern = RegExp(
    r'Եզրակացություն|Заключение|Conclusion|Result',
    caseSensitive: false,
  );

  static final _negativePattern = RegExp(
    r'Բացասական|Отрицательн\w*|Negative',
    caseSensitive: false,
  );

  static final _positivePattern = RegExp(
    r'Դրական|Положительн\w*|Positive',
    caseSensitive: false,
  );

  /// Ticks used by the labs we have seen.
  static final _tickPattern = RegExp(r'[✓✔☑х]', caseSensitive: false);

  bool isHelicobacterTest(String text) => _testPattern.hasMatch(text);

  List<LabMarker> parse(String text) {
    if (!isHelicobacterTest(text)) return const [];

    final positive = _isPositive(text);
    if (positive == null) return const [];

    return [
      LabMarker(
        id: 'h_pylori',
        name: 'Helicobacter pylori (breath test)',
        resultText: positive ? 'Positive' : 'Negative',
        unit: '',
        status: positive ? MarkerStatus.high : MarkerStatus.normal,
        referenceRange: 'Negative',
        information:
            'The urea breath test looks for Helicobacter pylori, a stomach '
            'bacterium linked with gastritis and ulcers. You drink a labelled '
            'urea solution and the lab measures the gas you breathe out.',
        description: positive
            ? 'A positive result means an active H. pylori infection was '
                'detected in your stomach.'
            : 'A negative result means no active H. pylori infection was '
                'detected at the time of the test.',
        recommendation: positive
            ? 'Positive results are usually treated with a short course of '
                'antibiotics plus acid-reducing medication. Take this report '
                'to your clinician to plan treatment and a follow-up test.'
            : 'No H. pylori treatment is indicated by this result. If stomach '
                'symptoms continue, discuss other causes with your clinician.',
        assayCode: 'H-PYLORI',
      ),
    ];
  }

  /// Returns true for positive, false for negative, null when no tick was
  /// found next to either label.
  bool? _isPositive(String text) {
    final conclusion = _conclusionPattern.firstMatch(text);
    // Consent pages carry their own ticks, so only read after the conclusion.
    final window = conclusion == null ? text : text.substring(conclusion.end);

    final negative = _negativePattern.firstMatch(window);
    final positive = _positivePattern.firstMatch(window);
    if (negative == null && positive == null) return null;

    int? best;
    bool? result;

    for (final tick in _tickPattern.allMatches(window)) {
      // The tick sits next to its label, so the nearest label wins.
      if (negative != null) {
        final distance = (tick.start - negative.end).abs();
        if (best == null || distance < best) {
          best = distance;
          result = false;
        }
      }
      if (positive != null) {
        final distance = (tick.start - positive.end).abs();
        if (best == null || distance < best) {
          best = distance;
          result = true;
        }
      }
    }

    return result;
  }
}
