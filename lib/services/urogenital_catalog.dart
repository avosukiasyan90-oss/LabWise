import '../models/lab_marker.dart';

enum _Expect {
  notDetected,
  belowThreshold,
  informational,
}

class _UroDef {
  const _UroDef({
    required this.id,
    required this.name,
    required this.patterns,
    required this.information,
    required this.description,
    required this.normalSuggestion,
    required this.abnormalSuggestion,
    this.expect = _Expect.notDetected,
    this.referenceRange = 'Not detected',
    this.unit = '',
  });

  final String id;
  final String name;
  final List<RegExp> patterns;
  final String information;
  final String description;
  final String normalSuggestion;
  final String abnormalSuggestion;
  final _Expect expect;
  final String referenceRange;
  final String unit;
}

/// Parses Russian urogenital smear microscopy + Androflor PCR panels.
class UrogenitalParser {
  static final List<_UroDef> _microscopy = [
    _UroDef(
      id: 'uro_leukocytes',
      name: 'Leukocytes (smear)',
      patterns: [RegExp(r'Лейкоцит', caseSensitive: false)],
      information: 'White blood cells seen on a urogenital smear.',
      description:
          'A low count in the field of view is common. Higher counts can suggest inflammation.',
      normalSuggestion: 'No strong inflammation signal from leukocytes alone.',
      abnormalSuggestion:
          'Elevated leukocytes on smear should be reviewed with symptoms by a clinician.',
      expect: _Expect.informational,
      referenceRange: 'Typically low (e.g. 0–5 / HPF)',
      unit: '/ HPF',
    ),
    _UroDef(
      id: 'uro_epithelial',
      name: 'Epithelial cells (smear)',
      patterns: [RegExp(r'Эпителиальн', caseSensitive: false)],
      information: 'Epithelial cells shed from the mucosal surface.',
      description: 'Moderate amounts are often normal on urogenital smears.',
      normalSuggestion: 'Usually informational unless other markers are abnormal.',
      abnormalSuggestion: 'Interpret epithelial cells with the full smear and symptoms.',
      expect: _Expect.informational,
      referenceRange: 'Variable / situational',
      unit: '/ HPF',
    ),
    _UroDef(
      id: 'uro_gonorrhea_smear',
      name: 'Gonorrhea (smear)',
      patterns: [RegExp(r'Гоноре', caseSensitive: false)],
      information: 'Microscopy screen for Neisseria gonorrhoeae-like findings.',
      description: '“Not detected” is the expected result on a routine smear.',
      normalSuggestion: 'No gonorrhea signal on this smear.',
      abnormalSuggestion:
          'Any positive smear finding needs urgent clinical confirmation and treatment advice.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'uro_mucus',
      name: 'Mucus (smear)',
      patterns: [RegExp(r'Слизь', caseSensitive: false)],
      information: 'Amount of mucus seen on microscopy.',
      description: 'Mild/moderate mucus can be normal; heavy mucus may accompany irritation.',
      normalSuggestion: 'Mild or moderate mucus is often not concerning alone.',
      abnormalSuggestion: 'Heavy mucus with symptoms should be reviewed clinically.',
      expect: _Expect.informational,
      referenceRange: 'Absent to moderate',
    ),
    _UroDef(
      id: 'uro_microflora',
      name: 'Microflora (smear)',
      patterns: [RegExp(r'Микрофлора', caseSensitive: false)],
      information: 'Overall bacterial appearance on the smear (e.g. cocci).',
      description: 'Describes the dominant flora pattern seen under the microscope.',
      normalSuggestion: 'Use together with PCR flora results for context.',
      abnormalSuggestion: 'Unusual flora patterns need clinical correlation.',
      expect: _Expect.informational,
      referenceRange: 'Situational',
    ),
    _UroDef(
      id: 'uro_yeast_smear',
      name: 'Yeast-like fungi (smear)',
      patterns: [RegExp(r'Дрожжеподобн', caseSensitive: false)],
      information: 'Microscopy screen for yeast-like fungi (Candida-like).',
      description: 'Not detected is expected when there is no candidiasis signal.',
      normalSuggestion: 'No yeast seen on smear.',
      abnormalSuggestion: 'Yeast on smear with symptoms may need antifungal review.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'uro_trichomonas_smear',
      name: 'Trichomoniasis (smear)',
      patterns: [RegExp(r'Трихомоноз', caseSensitive: false)],
      information: 'Microscopy screen for Trichomonas.',
      description: 'Not detected is the expected result.',
      normalSuggestion: 'No Trichomonas seen on smear.',
      abnormalSuggestion: 'Positive findings need clinical confirmation and treatment.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'uro_gardnerella_smear',
      name: 'Gardnerellosis (smear)',
      patterns: [RegExp(r'Гарднереллез', caseSensitive: false)],
      information: 'Microscopy screen related to Gardnerella-associated findings.',
      description: 'Not detected is expected on a clear smear.',
      normalSuggestion: 'No Gardnerella-associated signal on smear.',
      abnormalSuggestion: 'Discuss with a clinician if symptoms of dysbiosis are present.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'uro_other_pathogens_smear',
      name: 'Other pathogens (smear)',
      patterns: [RegExp(r'Прочие возбудител', caseSensitive: false)],
      information: 'Catch-all microscopy line for other visible pathogens.',
      description: 'Not detected means none were reported on microscopy.',
      normalSuggestion: 'No additional pathogens noted on smear.',
      abnormalSuggestion: 'Any detected pathogen should be reviewed by a clinician.',
      expect: _Expect.notDetected,
    ),
  ];

  static final List<_UroDef> _pcr = [
    _UroDef(
      id: 'af_human_dna',
      name: 'Human genomic DNA',
      patterns: [
        RegExp(r'Геномная ДНК человека', caseSensitive: false),
        RegExp(r'Human genomic DNA', caseSensitive: false),
      ],
      information: 'Control showing enough human DNA was present in the sample.',
      description: 'Used as a sample-quality control for PCR panels.',
      normalSuggestion: 'Sample quality control looks adequate.',
      abnormalSuggestion: 'Low human DNA can mean a poor sample — ask the lab/clinician.',
      expect: _Expect.belowThreshold,
      referenceRange: '> 10^4 (lab control)',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_total_bacteria',
      name: 'Total bacterial mass',
      patterns: [
        RegExp(r'Общая бактериальная масса', caseSensitive: false),
        RegExp(r'Total bacterial', caseSensitive: false),
      ],
      information: 'Overall bacterial load in the urogenital sample.',
      description: 'Reflects how much bacterial DNA was detected overall.',
      normalSuggestion: 'Interpret with the flora breakdown below.',
      abnormalSuggestion: 'Very low total mass can mean sparse flora or sampling issues.',
      expect: _Expect.belowThreshold,
      referenceRange: '> 10^3 (lab control)',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_lactobacillus',
      name: 'Lactobacillus spp.',
      patterns: [RegExp(r'Lactobacillus\s*spp\.?', caseSensitive: false)],
      information: 'Beneficial lactobacilli that often support a healthy mucosal flora.',
      description: 'In male Androflor panels, low/absent lactobacilli is common and contextual.',
      normalSuggestion: 'Absence can be acceptable in male urogenital PCR — confirm with clinician.',
      abnormalSuggestion: 'Discuss flora balance if there are symptoms.',
      expect: _Expect.informational,
      referenceRange: '<10% of total bacterial mass (panel note)',
    ),
    _UroDef(
      id: 'af_staphylococcus',
      name: 'Staphylococcus spp.',
      patterns: [RegExp(r'Staphylococcus\s*spp\.?', caseSensitive: false)],
      information: 'Staphylococci can be part of skin/urogenital flora.',
      description: 'Interpreted as part of the normal flora group in Androflor.',
      normalSuggestion: 'Review with the total normal-flora percentage.',
      abnormalSuggestion: 'High loads with symptoms may need clinical review.',
      expect: _Expect.informational,
      referenceRange: 'Part of normal flora group',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_streptococcus',
      name: 'Streptococcus spp.',
      patterns: [RegExp(r'Streptococcus\s*spp\.?', caseSensitive: false)],
      information: 'Streptococci may appear in urogenital flora PCR.',
      description: 'Counted toward the normal-flora sum in Androflor reports.',
      normalSuggestion: 'Interpret with the flora percentage summary.',
      abnormalSuggestion: 'High loads with symptoms deserve clinical context.',
      expect: _Expect.informational,
      referenceRange: 'Part of normal flora group',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_corynebacterium',
      name: 'Corynebacterium spp.',
      patterns: [RegExp(r'Corynebacterium\s*spp\.?', caseSensitive: false)],
      information: 'Corynebacteria are common mucosal/skin flora organisms.',
      description: 'Included in the normal-flora group on Androflor.',
      normalSuggestion: 'Usually reviewed as part of overall flora balance.',
      abnormalSuggestion: 'Persistent symptoms with high loads need clinician input.',
      expect: _Expect.informational,
      referenceRange: 'Part of normal flora group',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_normoflora_sum',
      name: 'Normal flora sum',
      patterns: [
        RegExp(r'Сумма:\s*Нормофлора', caseSensitive: false),
      ],
      information: 'Combined share of organisms labeled as normal flora.',
      description: 'Androflor often expects a higher share of normal flora (e.g. ≥60%).',
      normalSuggestion: 'Good normal-flora share supports a balanced profile.',
      abnormalSuggestion:
          'Low normal-flora percentage can mean dysbiosis — discuss with a clinician.',
      expect: _Expect.informational,
      referenceRange: 'Often ≥60%',
      unit: '%',
    ),
    _UroDef(
      id: 'af_gardnerella',
      name: 'Gardnerella vaginalis',
      patterns: [RegExp(r'Gardnerella\s*vaginalis', caseSensitive: false)],
      information: 'Opportunistic organism linked to bacterial vaginosis-type imbalance.',
      description: 'Not detected is preferred on many male Androflor panels.',
      normalSuggestion: 'Not detected — good for this marker.',
      abnormalSuggestion: 'Detection with symptoms should be reviewed clinically.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_megasphaera',
      name: 'Megasphaera / Veillonella / Dialister',
      patterns: [
        RegExp(r'Megasphaera\s*spp\.?/?\s*Veillonella', caseSensitive: false),
        RegExp(r'Megasphaera', caseSensitive: false),
      ],
      information: 'Group of anaerobic opportunistic bacteria (UPM).',
      description: 'Labs often flag loads above a log threshold (e.g. <10^4).',
      normalSuggestion: 'Within the lab threshold when below the stated cutoff.',
      abnormalSuggestion: 'Above-threshold UPM may need clinical correlation.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^4',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_sneathia',
      name: 'Sneathia / Leptotrichia / Fusobacterium',
      patterns: [
        RegExp(r'Sneathia\s*spp\.?/?\s*Leptotrichia', caseSensitive: false),
        RegExp(r'Sneathia', caseSensitive: false),
      ],
      information: 'Anaerobic opportunistic cluster on Androflor panels.',
      description: 'Usually expected below a lab log cutoff (e.g. <10^3).',
      normalSuggestion: 'Below cutoff is typically reassuring.',
      abnormalSuggestion: 'Elevated anaerobic UPM should be reviewed with symptoms.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^3',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_ureaplasma_urealyticum',
      name: 'Ureaplasma urealyticum',
      patterns: [RegExp(r'Ureaplasma\s*urealyticum', caseSensitive: false)],
      information: 'Mycoplasma-family organism sometimes linked to urethritis.',
      description: 'Not detected is preferred unless your clinician says otherwise.',
      normalSuggestion: 'Not detected.',
      abnormalSuggestion: 'Detection may need clinician follow-up, especially with symptoms.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_ureaplasma_parvum',
      name: 'Ureaplasma parvum',
      patterns: [RegExp(r'Ureaplasma\s*parvum', caseSensitive: false)],
      information: 'Common Ureaplasma species; significance depends on symptoms and load.',
      description: 'Many panels list “not detected” as the reference expectation.',
      normalSuggestion: 'Not detected is ideal; low loads are still clinician-dependent.',
      abnormalSuggestion:
          'Detected Ureaplasma parvum — discuss symptoms and whether treatment is needed.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_mycoplasma_hominis',
      name: 'Mycoplasma hominis',
      patterns: [RegExp(r'Mycoplasma\s*hominis', caseSensitive: false)],
      information: 'Opportunistic mycoplasma species.',
      description: 'Not detected is the preferred reference on this panel.',
      normalSuggestion: 'Not detected.',
      abnormalSuggestion: 'Positive results need clinical interpretation.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_atopobium',
      name: 'Atopobium cluster',
      patterns: [RegExp(r'Atopobium\s*cluster', caseSensitive: false)],
      information: 'Anaerobic cluster associated with dysbiosis in some contexts.',
      description: 'Often expected below a log cutoff (e.g. <10^3).',
      normalSuggestion: 'Below cutoff is typically fine.',
      abnormalSuggestion: 'Above-threshold loads deserve clinician review.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^3',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_upm_sum',
      name: 'Opportunistic flora (UPM) sum',
      patterns: [RegExp(r'Сумма:\s*УПМ(?!\s*анаэро)', caseSensitive: false)],
      information: 'Combined opportunistic (UPM) bacterial contribution.',
      description: 'Higher UPM share can accompany imbalance.',
      normalSuggestion: 'Low UPM percentage is generally preferable.',
      abnormalSuggestion: 'Elevated UPM share should be reviewed with a clinician.',
      expect: _Expect.informational,
      referenceRange: 'Lower is generally better',
      unit: '%',
    ),
    _UroDef(
      id: 'af_bacteroides',
      name: 'Bacteroides / Porphyromonas / Prevotella',
      patterns: [
        RegExp(r'Bacteroides\s*spp\.?/?\s*Porphyromonas', caseSensitive: false),
        RegExp(r'Bascteroides\s*spp\.?/?\s*Porphyromonas', caseSensitive: false),
        RegExp(r'Prevotella\s*spp', caseSensitive: false),
      ],
      information: 'Anaerobic opportunistic group on Androflor.',
      description: 'Labs often use a cutoff such as <10^3.',
      normalSuggestion: 'Below cutoff is usually reassuring.',
      abnormalSuggestion: 'Elevated anaerobic load — clinical correlation advised.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^3',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_anaerococcus',
      name: 'Anaerococcus spp.',
      patterns: [RegExp(r'Anaerococcus\s*spp\.?', caseSensitive: false)],
      information: 'Anaerobic opportunistic organism group.',
      description: 'Often expected below <10^4 on this panel style.',
      normalSuggestion: 'Below cutoff is typically fine.',
      abnormalSuggestion: 'Above-threshold result — ask your clinician.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^4',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_peptostreptococcus',
      name: 'Peptostreptococcus / Parvimonas',
      patterns: [
        RegExp(r'Peptostreptococcus\s*spp\.?/?\s*Parvimonas', caseSensitive: false),
        RegExp(r'Peptostreptococcus', caseSensitive: false),
      ],
      information: 'Anaerobic opportunistic cluster.',
      description: 'Common cutoff style is <10^4.',
      normalSuggestion: 'Below cutoff is typically fine.',
      abnormalSuggestion: 'Elevated load may need review if symptomatic.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^4',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_eubacterium',
      name: 'Eubacterium spp.',
      patterns: [RegExp(r'Eubacterium\s*spp\.?', caseSensitive: false)],
      information: 'Anaerobic opportunistic organism group.',
      description: 'Often expected below <10^4.',
      normalSuggestion: 'Below cutoff is typically fine.',
      abnormalSuggestion: 'Above-threshold result — clinical context needed.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^4',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_upm_anaerobe_sum',
      name: 'Anaerobic UPM sum',
      patterns: [
        RegExp(r'Сумма:\s*УПМ\s*анаэробы', caseSensitive: false),
      ],
      information: 'Combined anaerobic opportunistic flora share.',
      description: 'A higher anaerobic UPM percentage can suggest imbalance.',
      normalSuggestion: 'Lower anaerobic UPM share is generally preferable.',
      abnormalSuggestion: 'Elevated anaerobic UPM share — discuss with a clinician.',
      expect: _Expect.informational,
      referenceRange: 'Lower is generally better',
      unit: '%',
    ),
    _UroDef(
      id: 'af_haemophilus',
      name: 'Haemophilus spp.',
      patterns: [RegExp(r'Haemophilus\s*spp\.?', caseSensitive: false)],
      information: 'Opportunistic Haemophilus group on Androflor.',
      description: 'Often expected below <10^3.',
      normalSuggestion: 'Below cutoff is typically fine.',
      abnormalSuggestion: 'Elevated Haemophilus load — clinician review if symptomatic.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^3',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_pseudomonas',
      name: 'Pseudomonas / Ralstonia / Burkholderia',
      patterns: [
        RegExp(
          r'Pseudomonas\s*aeruginosa/?\s*Ralstonia',
          caseSensitive: false,
        ),
        RegExp(r'Pseudomonas\s*aeruginosa', caseSensitive: false),
      ],
      information: 'Opportunistic Gram-negative group.',
      description: 'Not detected or below cutoff is preferred.',
      normalSuggestion: 'Not detected / below cutoff.',
      abnormalSuggestion: 'Detection may need clinical follow-up.',
      expect: _Expect.notDetected,
      referenceRange: '< 10^3 / not detected',
    ),
    _UroDef(
      id: 'af_enterobacteriaceae',
      name: 'Enterobacteriaceae / Enterococcus',
      patterns: [
        RegExp(r'Enterobacteriaceae/?\s*Enterococcus', caseSensitive: false),
        RegExp(r'Enterobacteriaceae', caseSensitive: false),
      ],
      information: 'Gut-associated opportunistic bacteria that can colonize the urogenital tract.',
      description: 'Often expected below a cutoff such as <10^4.',
      normalSuggestion: 'Below cutoff is typically fine.',
      abnormalSuggestion:
          'Elevated Enterobacteriaceae/Enterococcus — discuss symptoms with a clinician.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^4',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_candida',
      name: 'Candida spp.',
      patterns: [RegExp(r'Candida\s*spp\.?', caseSensitive: false)],
      information: 'Yeast (Candida) DNA load on PCR.',
      description: 'Often expected below <10^4; symptoms matter for treatment decisions.',
      normalSuggestion: 'Below cutoff without symptoms is often observed.',
      abnormalSuggestion: 'Elevated Candida with symptoms may need antifungal review.',
      expect: _Expect.belowThreshold,
      referenceRange: '< 10^4',
      unit: 'log10 copies',
    ),
    _UroDef(
      id: 'af_mycoplasma_genitalium',
      name: 'Mycoplasma genitalium',
      patterns: [RegExp(r'Mycoplasma\s*genitalium', caseSensitive: false)],
      information: 'Sexually associated pathogen; treat only with clinician guidance.',
      description: 'Not detected is the expected result.',
      normalSuggestion: 'Not detected.',
      abnormalSuggestion: 'Positive result needs clinician-directed care.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_trichomonas',
      name: 'Trichomonas vaginalis',
      patterns: [RegExp(r'Trichomonas\s*vaginalis', caseSensitive: false)],
      information: 'Protozoal STI pathogen.',
      description: 'Not detected is expected.',
      normalSuggestion: 'Not detected.',
      abnormalSuggestion: 'Positive result needs prompt clinical care.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_neisseria',
      name: 'Neisseria gonorrhoeae',
      patterns: [RegExp(r'Neisseria\s*gonorrhoeae', caseSensitive: false)],
      information: 'Gonorrhea PCR target.',
      description: 'Not detected is expected.',
      normalSuggestion: 'Not detected.',
      abnormalSuggestion: 'Positive gonorrhea PCR needs urgent clinician care.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_chlamydia',
      name: 'Chlamydia trachomatis',
      patterns: [RegExp(r'Chlamydia\s*trachomatis', caseSensitive: false)],
      information: 'Chlamydia PCR target.',
      description: 'Not detected is expected.',
      normalSuggestion: 'Not detected.',
      abnormalSuggestion: 'Positive chlamydia PCR needs clinician-directed treatment.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_hsv1',
      name: 'HSV-1',
      patterns: [
        RegExp(r'Herpes\s*Simplex\s*Virus\s*Type\s*1', caseSensitive: false),
        RegExp(r'\bHSV-1\b', caseSensitive: false),
      ],
      information: 'Herpes simplex virus type 1 DNA.',
      description: 'Not detected means no HSV-1 DNA found in this sample.',
      normalSuggestion: 'Not detected in this sample.',
      abnormalSuggestion: 'Detection should be interpreted by a clinician.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_hsv2',
      name: 'HSV-2',
      patterns: [
        RegExp(r'Herpes\s*Simplex\s*Virus\s*Type\s*2', caseSensitive: false),
        RegExp(r'\bHSV-2\b', caseSensitive: false),
      ],
      information: 'Herpes simplex virus type 2 DNA.',
      description: 'Not detected means no HSV-2 DNA found in this sample.',
      normalSuggestion: 'Not detected in this sample.',
      abnormalSuggestion: 'Detection should be interpreted by a clinician.',
      expect: _Expect.notDetected,
    ),
    _UroDef(
      id: 'af_cmv',
      name: 'Cytomegalovirus (CMV)',
      patterns: [
        RegExp(r'Citomegalovirus', caseSensitive: false),
        RegExp(r'Cytomegalovirus', caseSensitive: false),
        RegExp(r'\bCMV\b'),
      ],
      information: 'Cytomegalovirus DNA in the sample.',
      description: 'Not detected means no CMV DNA found here.',
      normalSuggestion: 'Not detected in this sample.',
      abnormalSuggestion: 'Detection needs clinician interpretation.',
      expect: _Expect.notDetected,
    ),
  ];

  bool isUrogenitalReport(String text) {
    final lower = text.toLowerCase();
    return lower.contains('андрофлор') ||
        lower.contains('androflor') ||
        lower.contains('урогенитал') ||
        lower.contains('urogenital') ||
        text.contains('МИКРОСКОПИЧЕСКИХ ИССЛЕДОВАНИЙ') ||
        text.contains('БИОЦЕНОЗА УРОГЕНИТАЛЬНОГО');
  }

  /// Joins split scientific notation like `10\n4.3` → `10^4.3`.
  String normalizeScientificNotation(String text) {
    return text.replaceAllMapped(
      RegExp(r'(?<![\d.])10\s*[\r\n]+\s*(\d+(?:[.,]\d+)?)'),
      (m) => '10^${m.group(1)!.replaceAll(',', '.')}',
    );
  }

  List<LabMarker> parse(String text) {
    if (!isUrogenitalReport(text)) return const [];
    final normalized = normalizeScientificNotation(text);
    final markers = <LabMarker>[];
    final seen = <String>{};

    for (final def in [..._microscopy, ..._pcr]) {
      if (seen.contains(def.id)) continue;
      for (final pattern in def.patterns) {
        final match = pattern.firstMatch(normalized);
        if (match == null) continue;
        final windowEnd = (match.end + 220).clamp(0, normalized.length);
        final window = normalized.substring(match.start, windowEnd);
        final marker = _parseWindow(def, window);
        if (marker == null) continue;
        markers.add(marker);
        seen.add(def.id);
        break;
      }
    }
    return markers;
  }

  LabMarker? _parseWindow(_UroDef def, String window) {
    final notDetected = RegExp(
      r'не\s*обнаружен[аоы]?|not\s*detected|negative',
      caseSensitive: false,
    ).firstMatch(window);

    final sci = RegExp(
      r'10\s*\^\s*(\d+(?:[.,]\d+)?)',
      caseSensitive: false,
    ).firstMatch(window);

    final percent = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*%',
    ).firstMatch(window);

    final hpf = RegExp(
      r'(\d+\s*[-–—]\s*\d+)\s*в\s*п/?з',
      caseSensitive: false,
    ).firstMatch(window);

    final mucusOrFlora = RegExp(
      r'(умеренн\w*|обильн\w*|скудн\w*|отсутств\w*|moderate|scanty|abundant)[^\n]{0,40}',
      caseSensitive: false,
    ).firstMatch(window);

    String? resultText;
    double? value;
    MarkerStatus status = MarkerStatus.unknown;
    var unit = def.unit;
    var reference = def.referenceRange;

    // Prefer the earliest concrete token so later rows in the same window
    // (e.g. "не обнаружена" on the next smear line) do not steal the result.
    // Flora "sum" rows also print a log10 mass before the percentage — keep %.
    final preferPercent = def.unit == '%' || def.id.endsWith('_sum');
    final candidates = <({int start, String kind})>[
      if (hpf != null) (start: hpf.start, kind: 'hpf'),
      if (mucusOrFlora != null) (start: mucusOrFlora.start, kind: 'desc'),
      if (preferPercent && percent != null) (start: percent.start, kind: 'pct'),
      if (sci != null) (start: sci.start, kind: 'sci'),
      if (!preferPercent && percent != null) (start: percent.start, kind: 'pct'),
      if (notDetected != null) (start: notDetected.start, kind: 'neg'),
    ]..sort((a, b) {
      // When preferring %, force pct ahead of sci even if sci appears first.
      if (preferPercent) {
        if (a.kind == 'pct' && b.kind == 'sci') return -1;
        if (a.kind == 'sci' && b.kind == 'pct') return 1;
      }
      return a.start.compareTo(b.start);
    });

    if (candidates.isEmpty) return null;
    final kind = candidates.first.kind;

    if (kind == 'hpf') {
      resultText = '${hpf!.group(1)} / HPF';
      unit = '/ HPF';
      status = MarkerStatus.normal;
    } else if (kind == 'desc') {
      resultText = mucusOrFlora!.group(0)!.trim();
      status = MarkerStatus.normal;
    } else if (kind == 'sci') {
      final exp = double.tryParse(sci!.group(1)!.replaceAll(',', '.'));
      if (exp == null) return null;
      value = exp;
      resultText = '10^${sci.group(1)!.replaceAll(',', '.')}';
      unit = unit.isEmpty ? 'log10 copies' : unit;
      status = _statusForScientific(def, window, exp);
      final cutoff = RegExp(
        r'<\s*10\s*\^\s*(\d+(?:[.,]\d+)?)',
        caseSensitive: false,
      ).firstMatch(window);
      if (cutoff != null) {
        reference = '< 10^${cutoff.group(1)!.replaceAll(',', '.')}';
      }
    } else if (kind == 'pct') {
      value = double.tryParse(percent!.group(1)!.replaceAll(',', '.'));
      resultText = '${percent.group(1)!.replaceAll(',', '.')}%';
      unit = '%';
      status = _statusForPercent(def, value);
    } else {
      resultText = 'Not detected';
      status = def.expect == _Expect.notDetected ||
              def.expect == _Expect.belowThreshold
          ? MarkerStatus.normal
          : MarkerStatus.unknown;
    }

    return LabMarker(
      id: def.id,
      name: def.name,
      value: value,
      resultText: resultText,
      unit: unit,
      status: status,
      referenceRange: reference,
      information: def.information,
      description: def.description,
      recommendation: status == MarkerStatus.normal ||
              status == MarkerStatus.unknown
          ? def.normalSuggestion
          : def.abnormalSuggestion,
    );
  }

  MarkerStatus _statusForScientific(_UroDef def, String window, double exp) {
    if (def.expect == _Expect.notDetected) {
      return MarkerStatus.high;
    }
    if (def.expect == _Expect.belowThreshold) {
      final cutoff = RegExp(
        r'<\s*10\s*\^\s*(\d+(?:[.,]\d+)?)',
        caseSensitive: false,
      ).firstMatch(window);
      if (cutoff != null) {
        final max = double.tryParse(cutoff.group(1)!.replaceAll(',', '.'));
        if (max != null) {
          return exp >= max ? MarkerStatus.high : MarkerStatus.normal;
        }
      }
      // Human DNA / total mass use ">" controls.
      final minCut = RegExp(
        r'>\s*10\s*\^\s*(\d+(?:[.,]\d+)?)',
        caseSensitive: false,
      ).firstMatch(window);
      if (minCut != null) {
        final min = double.tryParse(minCut.group(1)!.replaceAll(',', '.'));
        if (min != null) {
          return exp >= min ? MarkerStatus.normal : MarkerStatus.low;
        }
      }
      return MarkerStatus.unknown;
    }
    return MarkerStatus.unknown;
  }

  MarkerStatus _statusForPercent(_UroDef def, double? value) {
    if (value == null) return MarkerStatus.unknown;
    if (def.id == 'af_normoflora_sum') {
      return value >= 60 ? MarkerStatus.normal : MarkerStatus.low;
    }
    if (def.id == 'af_upm_sum' || def.id == 'af_upm_anaerobe_sum') {
      return value > 20 ? MarkerStatus.high : MarkerStatus.normal;
    }
    return MarkerStatus.unknown;
  }
}
