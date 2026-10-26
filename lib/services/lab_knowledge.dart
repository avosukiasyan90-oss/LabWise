import '../models/lab_marker.dart';
import 'cbc_catalog.dart';

class LabRanges {
  const LabRanges({
    required this.low,
    required this.high,
    required this.referenceRange,
    required this.unit,
  });

  final double low;
  final double high;
  final String referenceRange;
  final String unit;
}

class LabKnowledge {
  const LabKnowledge({
    required this.id,
    required this.name,
    required this.assayCodes,
    required this.namePatterns,
    required this.description,
    required this.information,
    required this.normalSuggestion,
    required this.lowSuggestion,
    required this.highSuggestion,
    required this.mgDl,
    this.mmolL,
  });

  final String id;
  final String name;
  final List<String> assayCodes;
  final List<RegExp> namePatterns;
  final String description;
  final String information;
  final String normalSuggestion;
  final String lowSuggestion;
  final String highSuggestion;
  final LabRanges mgDl;
  final LabRanges? mmolL;

  String suggestionFor(MarkerStatus status) {
    return switch (status) {
      MarkerStatus.low => lowSuggestion,
      MarkerStatus.high => highSuggestion,
      MarkerStatus.normal => normalSuggestion,
      MarkerStatus.unknown =>
        'Share this result with your clinician for personalized guidance.',
    };
  }
}

class LabCatalog {
  static final List<LabKnowledge> all = [
    LabKnowledge(
      id: 'glucose',
      name: 'Glucose',
      assayCodes: const ['GLUC', 'GLU'],
      namePatterns: [
        RegExp(r'գլյուկոզա', caseSensitive: false),
        RegExp(r'\bglucose\b', caseSensitive: false),
      ],
      information:
          'Blood glucose shows how well your body is controlling sugar at the time of the test.',
      description:
          'Used to screen for diabetes risk and monitor metabolic health. Fasting values are most meaningful.',
      normalSuggestion:
          'Keep balanced meals, limit sugary drinks, and stay active most days.',
      lowSuggestion:
          'Eat a balanced snack if you feel shaky or dizzy, and ask your clinician if low values repeat.',
      highSuggestion:
          'Reduce sugary drinks, walk after meals, and discuss diabetes screening with your doctor.',
      mgDl: const LabRanges(
        low: 70,
        high: 99,
        referenceRange: '70–99 mg/dL',
        unit: 'mg/dL',
      ),
      mmolL: const LabRanges(
        low: 4.11,
        high: 5.89,
        referenceRange: '4.11–5.89 mmol/L',
        unit: 'mmol/L',
      ),
    ),
    LabKnowledge(
      id: 'cholesterol',
      name: 'Total Cholesterol',
      assayCodes: const ['CHOL', 'TC'],
      namePatterns: [
        RegExp(r'խոլեստերին', caseSensitive: false),
        RegExp(r'\bcholesterol\b(?!\s*(hdl|ldl))', caseSensitive: false),
      ],
      information:
          'Total cholesterol is the overall amount of cholesterol circulating in your blood.',
      description:
          'Higher totals can raise long-term cardiovascular risk, especially with elevated LDL.',
      normalSuggestion:
          'Continue heart-healthy eating with fiber, vegetables, and regular movement.',
      lowSuggestion:
          'Very low cholesterol is uncommon — mention it at your next clinical visit.',
      highSuggestion:
          'Prefer fiber-rich foods, reduce ultra-processed fats, and plan a clinician follow-up.',
      mgDl: const LabRanges(
        low: 0,
        high: 200,
        referenceRange: '< 200 mg/dL',
        unit: 'mg/dL',
      ),
      mmolL: const LabRanges(
        low: 0,
        high: 5.2,
        referenceRange: '< 5.2 mmol/L',
        unit: 'mmol/L',
      ),
    ),
    LabKnowledge(
      id: 'ldl',
      name: 'LDL Cholesterol',
      assayCodes: const ['LDL-C', 'LDL', 'LDLC'],
      namePatterns: [
        RegExp(r'ցածր\s*խտության', caseSensitive: false),
        RegExp(r'low[- ]density\s*lipoprotein', caseSensitive: false),
        RegExp(r'\bldl\b', caseSensitive: false),
      ],
      information:
          'LDL is often called “bad” cholesterol because excess can build up in arteries.',
      description:
          'One of the most important markers for heart and vessel risk assessment.',
      normalSuggestion:
          'Maintain olive oil, nuts, fish, vegetables, and consistent exercise.',
      lowSuggestion: 'Low LDL is generally favorable — keep your current habits.',
      highSuggestion:
          'Cut fried/ultra-processed foods, increase soluble fiber, and discuss next steps with your doctor.',
      mgDl: const LabRanges(
        low: 0,
        high: 100,
        referenceRange: '< 100 mg/dL',
        unit: 'mg/dL',
      ),
      mmolL: const LabRanges(
        low: 0,
        high: 2.6,
        referenceRange: '< 2.6 mmol/L',
        unit: 'mmol/L',
      ),
    ),
    LabKnowledge(
      id: 'hdl',
      name: 'HDL Cholesterol',
      assayCodes: const ['HDL-C', 'HDL', 'HDLC'],
      namePatterns: [
        RegExp(r'բարձր\s*խտության', caseSensitive: false),
        RegExp(r'high[- ]density\s*lipoprotein', caseSensitive: false),
        RegExp(r'\bhdl\b', caseSensitive: false),
      ],
      information:
          'HDL helps transport cholesterol away from tissues and is usually protective when higher.',
      description:
          'Low HDL can increase cardiovascular risk, especially with high LDL or triglycerides.',
      normalSuggestion:
          'Keep brisk walking, strength training, and avoid smoking if applicable.',
      lowSuggestion:
          'Increase daily activity and heart-healthy fats; ask your clinician about overall lipid risk.',
      highSuggestion:
          'Higher HDL is usually protective — continue the habits that support it.',
      mgDl: const LabRanges(
        low: 40,
        high: 999,
        referenceRange: '≥ 40 mg/dL',
        unit: 'mg/dL',
      ),
      mmolL: const LabRanges(
        low: 1.45,
        high: 999,
        referenceRange: '> 1.45 mmol/L',
        unit: 'mmol/L',
      ),
    ),
    LabKnowledge(
      id: 'triglycerides',
      name: 'Triglycerides',
      assayCodes: const ['TRIGL', 'TRIG', 'TG'],
      namePatterns: [
        RegExp(r'տրիգլիցերիդ', caseSensitive: false),
        RegExp(r'triglycerides?', caseSensitive: false),
      ],
      information:
          'Triglycerides are blood fats strongly influenced by sugar, alcohol, and calorie surplus.',
      description:
          'Useful for metabolic and cardiovascular risk review alongside cholesterol markers.',
      normalSuggestion:
          'Keep evening meals lighter and limit sugary drinks and excess alcohol.',
      lowSuggestion: 'Low triglycerides are usually fine.',
      highSuggestion:
          'Cut sugary drinks/alcohol, choose whole grains, and recheck with your clinician as advised.',
      mgDl: const LabRanges(
        low: 0,
        high: 150,
        referenceRange: '< 150 mg/dL',
        unit: 'mg/dL',
      ),
      mmolL: const LabRanges(
        low: 0,
        high: 2.26,
        referenceRange: '< 2.26 mmol/L',
        unit: 'mmol/L',
      ),
    ),
    LabKnowledge(
      id: 'hba1c',
      name: 'HbA1c',
      assayCodes: const ['HBA1C', 'A1C'],
      namePatterns: [
        RegExp(r'hba1c|hb\s*a1c|\ba1c\b|glycated\s*hemoglobin',
            caseSensitive: false),
      ],
      information:
          'HbA1c reflects average blood sugar over roughly the last 2–3 months.',
      description:
          'Helps identify longer-term glucose control beyond a single fasting test.',
      normalSuggestion:
          'Maintain fiber-rich meals, activity, and routine checkups.',
      lowSuggestion:
          'Unusually low A1c is uncommon — confirm with your clinician if symptomatic.',
      highSuggestion:
          'Focus on meal quality and movement, and schedule clinical follow-up.',
      mgDl: const LabRanges(
        low: 4.0,
        high: 5.6,
        referenceRange: '4.0–5.6%',
        unit: '%',
      ),
    ),
    LabKnowledge(
      id: 'hemoglobin',
      name: 'Hemoglobin',
      assayCodes: const ['HGB', 'HB'],
      namePatterns: [
        RegExp(r'\bhemoglobin\b|\bhgb\b', caseSensitive: false),
      ],
      information: 'Hemoglobin carries oxygen in red blood cells.',
      description: 'Low values can indicate anemia; high values need clinical context.',
      normalSuggestion: 'Keep iron-rich nutrition and good hydration.',
      lowSuggestion:
          'Discuss possible anemia evaluation and iron-rich foods with your clinician.',
      highSuggestion:
          'Hydrate and ask your clinician if high hemoglobin persists.',
      mgDl: const LabRanges(
        low: 12.0,
        high: 17.5,
        referenceRange: '≈ 12–17.5 g/dL',
        unit: 'g/dL',
      ),
    ),
    LabKnowledge(
      id: 'wbc',
      name: 'White Blood Cells',
      assayCodes: const ['WBC'],
      namePatterns: [
        RegExp(r'white\s*blood\s*cells?|\bwbc\b|leukocytes?',
            caseSensitive: false),
      ],
      information: 'White blood cells are part of your immune defense.',
      description:
          'Can rise with infection/inflammation and fall with some illnesses or medications.',
      normalSuggestion: 'No special action if you feel well.',
      lowSuggestion:
          'Rest and avoid sick contacts; ask your clinician if this continues.',
      highSuggestion:
          'Monitor symptoms like fever and seek medical advice if unwell.',
      mgDl: const LabRanges(
        low: 4.0,
        high: 11.0,
        referenceRange: '4.0–11.0 ×10³/µL',
        unit: '×10³/µL',
      ),
    ),
    LabKnowledge(
      id: 'platelets',
      name: 'Platelets',
      assayCodes: const ['PLT'],
      namePatterns: [
        RegExp(r'platelets?|\bplt\b', caseSensitive: false),
      ],
      information: 'Platelets help your blood clot after injury.',
      description: 'Abnormal levels can affect bleeding or clotting risk.',
      normalSuggestion: 'Continue routine care unless symptoms appear.',
      lowSuggestion:
          'Avoid contact sports until a clinician reviews bleeding risk.',
      highSuggestion:
          'Stay hydrated and attend recommended follow-up testing.',
      mgDl: const LabRanges(
        low: 150,
        high: 450,
        referenceRange: '150–450 ×10³/µL',
        unit: '×10³/µL',
      ),
    ),
    LabKnowledge(
      id: 'vitamin_d',
      name: 'Vitamin D (25-OH)',
      assayCodes: const ['VITD', 'VD'],
      namePatterns: [
        RegExp(r'vitamin\s*d|25[- ]?oh|25[- ]?hydroxy', caseSensitive: false),
      ],
      information: 'Vitamin D supports bones, mood, and immune balance.',
      description: 'Deficiency is common and often improvable with guided supplementation.',
      normalSuggestion: 'Keep safe daylight habits and balanced nutrition.',
      lowSuggestion:
          'Ask about vitamin D supplementation and safe sun exposure.',
      highSuggestion:
          'Pause supplements and check dosing with your clinician.',
      mgDl: const LabRanges(
        low: 30,
        high: 100,
        referenceRange: '30–100 ng/mL',
        unit: 'ng/mL',
      ),
    ),
    LabKnowledge(
      id: 'tsh',
      name: 'TSH',
      assayCodes: const ['TSH'],
      namePatterns: [
        RegExp(r'\btsh\b|thyroid\s*stimulating', caseSensitive: false),
      ],
      information: 'TSH shows how your thyroid is being stimulated.',
      description: 'Abnormal TSH can relate to under- or over-active thyroid function.',
      normalSuggestion: 'Continue routine thyroid monitoring as advised.',
      lowSuggestion:
          'Note palpitations/heat intolerance and discuss thyroid evaluation.',
      highSuggestion:
          'Watch for fatigue/cold sensitivity and discuss treatment options.',
      mgDl: const LabRanges(
        low: 0.4,
        high: 4.0,
        referenceRange: '≈ 0.4–4.0 mIU/L',
        unit: 'mIU/L',
      ),
    ),
    LabKnowledge(
      id: 'creatinine',
      name: 'Creatinine',
      assayCodes: const ['CREA', 'CREAT'],
      namePatterns: [
        RegExp(r'\bcreatinine\b', caseSensitive: false),
      ],
      information: 'Creatinine is a common kidney function marker.',
      description: 'Interpreted with age, muscle mass, and other kidney tests.',
      normalSuggestion: 'Stay hydrated and avoid unnecessary NSAID overuse.',
      lowSuggestion:
          'Often related to lower muscle mass — usually not urgent.',
      highSuggestion:
          'Ask for kidney review; hydrate unless your clinician advises otherwise.',
      mgDl: const LabRanges(
        low: 0.6,
        high: 1.3,
        referenceRange: '≈ 0.6–1.3 mg/dL',
        unit: 'mg/dL',
      ),
      mmolL: const LabRanges(
        low: 53,
        high: 115,
        referenceRange: '≈ 53–115 µmol/L',
        unit: 'µmol/L',
      ),
    ),
    LabKnowledge(
      id: 'alt',
      name: 'ALT (liver enzyme)',
      assayCodes: const ['ALT', 'SGPT'],
      namePatterns: [
        RegExp(r'\balt\b|alanine\s*aminotransferase|sgpt',
            caseSensitive: false),
      ],
      information: 'ALT can rise when the liver is stressed or inflamed.',
      description: 'Often reviewed with AST and clinical symptoms.',
      normalSuggestion: 'Keep alcohol moderate and maintain a balanced diet.',
      lowSuggestion: 'Low ALT is usually not a concern.',
      highSuggestion:
          'Limit alcohol and ask about liver follow-up if elevated.',
      mgDl: const LabRanges(
        low: 7,
        high: 56,
        referenceRange: '≈ 7–56 U/L',
        unit: 'U/L',
      ),
    ),
    LabKnowledge(
      id: 'ast',
      name: 'AST (liver enzyme)',
      assayCodes: const ['AST', 'SGOT'],
      namePatterns: [
        RegExp(r'\bast\b|aspartate\s*aminotransferase|sgot',
            caseSensitive: false),
      ],
      information: 'AST relates to liver and muscle health.',
      description: 'Can rise with liver stress, intense exercise, or other conditions.',
      normalSuggestion: 'No special action if you feel well.',
      lowSuggestion: 'Low AST is usually fine.',
      highSuggestion:
          'Rest from intense workouts before retesting if advised by your clinician.',
      mgDl: const LabRanges(
        low: 10,
        high: 40,
        referenceRange: '≈ 10–40 U/L',
        unit: 'U/L',
      ),
    ),
    LabKnowledge(
      id: 'iron',
      name: 'Serum Iron',
      assayCodes: const ['FE', 'IRON'],
      namePatterns: [
        RegExp(r'serum\s*iron|\biron\b(?!\s*binding)', caseSensitive: false),
      ],
      information: 'Serum iron reflects iron available in the blood.',
      description: 'Useful with ferritin and other anemia-related tests.',
      normalSuggestion: 'Keep a balanced diet with iron-containing foods.',
      lowSuggestion:
          'Pair iron-rich foods with vitamin C; ask before self-supplementing.',
      highSuggestion:
          'Do not take iron supplements unless prescribed.',
      mgDl: const LabRanges(
        low: 60,
        high: 170,
        referenceRange: '≈ 60–170 µg/dL',
        unit: 'µg/dL',
      ),
    ),
    LabKnowledge(
      id: 'b12',
      name: 'Vitamin B12',
      assayCodes: const ['B12', 'VB12'],
      namePatterns: [
        RegExp(r'vitamin\s*b\s*-?\s*12|\bb12\b|cobalamin',
            caseSensitive: false),
      ],
      information: 'Vitamin B12 supports nerves, energy, and red blood cells.',
      description: 'Low levels are more common with limited animal-product intake.',
      normalSuggestion: 'Maintain B12 sources through food or guided supplements.',
      lowSuggestion:
          'Discuss B12 testing/supplementation, especially if vegetarian/vegan.',
      highSuggestion:
          'High B12 is often from supplements — review doses with your clinician.',
      mgDl: const LabRanges(
        low: 200,
        high: 900,
        referenceRange: '≈ 200–900 pg/mL',
        unit: 'pg/mL',
      ),
    ),
  ];

  static Iterable<LabKnowledge> get _lookup sync* {
    yield* CbcCatalog.all;
    yield* all;
  }

  static LabKnowledge? byAssayCode(String code) {
    final upper = code.toUpperCase();
    for (final item in _lookup) {
      if (item.assayCodes.any((c) => c.toUpperCase() == upper)) return item;
    }
    return null;
  }

  static LabKnowledge? byName(String text) {
    for (final item in _lookup) {
      for (final pattern in item.namePatterns) {
        if (pattern.hasMatch(text)) return item;
      }
    }
    return null;
  }
}
