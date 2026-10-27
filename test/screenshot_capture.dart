// Renders App Store screenshots at Apple's required pixel sizes.
//
// Not named *_test.dart on purpose, so `flutter test` ignores it. Run with:
//   flutter test test/screenshot_capture.dart
//
// Output lands in .screenshots/<device>/.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthy_project/l10n/app_localizations.dart';
import 'package:healthy_project/models/lab_marker.dart';
import 'package:healthy_project/models/medical_report.dart';
import 'package:healthy_project/models/medication.dart';
import 'package:healthy_project/models/report_comparison.dart';
import 'package:healthy_project/models/user_profile.dart';
import 'package:healthy_project/screens/history_screen.dart';
import 'package:healthy_project/screens/medications_screen.dart';
import 'package:healthy_project/screens/results_screen.dart';
import 'package:healthy_project/screens/targets_screen.dart';
import 'package:healthy_project/services/wellness_planner.dart';
import 'package:healthy_project/theme/app_theme.dart';

/// Apple's required sizes, as physical pixels plus the matching scale factor.
class Device {
  const Device(this.name, this.pixels, this.dpr);
  final String name;
  final Size pixels;
  final double dpr;
}

const devices = [
  // iPhone 16 Pro — "iPhone with Dynamic Island (medium display)".
  Device('iphone-6.3', Size(1206, 2622), 3),
  // iPad Pro 13-inch.
  Device('ipad-13', Size(2064, 2752), 2),
];

/// Every weight google_fonts might ask for. Registering the variable font
/// under each name lets the real theme resolve without a download.
const _variants = [
  'regular', 'w100', 'w200', 'w300', 'w400', 'w500', 'w600', 'w700',
  'w800', 'w900', 'italic',
];

Future<void> loadFonts() async {
  // google_fonts would try to download these; registering them by the exact
  // family names it asks for lets the real theme render offline.
  final files = {
    'Fraunces': '.screenshots/fonts/Fraunces.ttf',
    'SourceSans3': '.screenshots/fonts/SourceSans3.ttf',
  };

  for (final entry in files.entries) {
    final bytes = File(entry.value).readAsBytesSync();
    for (final variant in _variants) {
      final loader = FontLoader('${entry.key}_$variant')
        ..addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
    }
  }

  // Without this every Icon renders as an empty box: the test environment
  // does not bundle the icon font.
  const iconFont =
      '/Users/avosukiasyan/fvm/versions/stable/bin/cache/artifacts/'
      'material_fonts/MaterialIcons-Regular.otf';
  final icons = File(iconFont);
  if (icons.existsSync()) {
    final bytes = icons.readAsBytesSync();
    await (FontLoader('MaterialIcons')
          ..addFont(Future.value(ByteData.view(bytes.buffer))))
        .load();
  }

  GoogleFonts.config.allowRuntimeFetching = false;
}

LabMarker marker(
  String id,
  String name,
  double value,
  String unit,
  MarkerStatus status,
  String range,
) =>
    LabMarker(
      id: id,
      name: name,
      unit: unit,
      status: status,
      value: value,
      referenceRange: range,
      information: 'This marker reflects how your body is handling fats in '
          'the blood over recent weeks.',
      recommendation: status == MarkerStatus.normal
          ? 'Keep doing what you are doing — this one looks settled.'
          : 'Favour fibre-rich food and regular movement, and plan a '
              'follow-up with your clinician.',
    );

MedicalReport buildReport() => MedicalReport(
      id: 'r1',
      fileName: 'Biochemistry — May 2026.pdf',
      uploadedAt: DateTime(2026, 5, 16, 10, 30),
      summary: 'Most values look settled. Two are outside their range and '
          'worth a conversation at your next visit.',
      whatToDo: const [
        'Keep walking after meals — it helps both glucose and cholesterol.',
        'Bring this report to your next appointment.',
      ],
      clinicName: '"VARDANANTS" Medical Centre',
      examTitle: 'Biochemical examination',
      patientName: 'A. SUKIASYAN',
      sampleDate: '16.05.2026',
      method: 'Photometric / enzymatic',
      previous: ReportSnapshot(
        id: 'r0',
        fileName: 'Biochemistry — January 2026.pdf',
        uploadedAt: DateTime(2026, 1, 10),
        markers: const [
          MarkerSnapshot(id: 'ldl', status: MarkerStatus.high, value: 200),
          MarkerSnapshot(id: 'hdl', status: MarkerStatus.low, value: 30),
          MarkerSnapshot(id: 'glucose', status: MarkerStatus.normal, value: 90),
          MarkerSnapshot(id: 'alt', status: MarkerStatus.normal, value: 22),
        ],
      ),
      markers: [
        marker('ldl', 'LDL cholesterol', 150, 'mg/dL', MarkerStatus.normal,
            '< 160'),
        marker('hdl', 'HDL cholesterol', 35, 'mg/dL', MarkerStatus.low,
            '> 40'),
        marker('glucose', 'Glucose', 92, 'mg/dL', MarkerStatus.normal,
            '74 – 106'),
        marker('alt', 'ALT', 48, 'U/L', MarkerStatus.high, '< 41'),
      ],
    );

List<MedicalReport> buildHistory() {
  final latest = buildReport();
  return [
    latest,
    MedicalReport(
      id: 'r2',
      fileName: 'Complete blood count.pdf',
      uploadedAt: DateTime(2026, 4, 2, 9, 15),
      summary: 'Everything in this panel sits inside its range.',
      whatToDo: const [],
      markers: List.generate(
        22,
        (i) => marker('cbc$i', 'Marker $i', 5, '', MarkerStatus.normal, '-'),
      ),
    ),
    MedicalReport(
      id: 'r3',
      fileName: 'Helicobacter breath test.pdf',
      uploadedAt: DateTime(2026, 2, 20, 14, 0),
      summary: 'The breath test came back negative.',
      whatToDo: const [],
      markers: [
        LabMarker(
          id: 'h_pylori',
          name: 'Helicobacter pylori (breath test)',
          unit: '',
          status: MarkerStatus.normal,
          resultText: 'Negative',
        ),
      ],
    ),
  ];
}

List<Medication> buildMedications() {
  final start = DateTime.now().subtract(const Duration(days: 20));
  return [
    Medication(
      id: 'm1',
      title: 'Vitamin D',
      count: 1,
      times: const [DoseTime(hour: 8, minute: 0)],
      startDate: start,
      takenKeys: {
        Medication.doseKey(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            8,
          ),
        ),
      },
    ),
    Medication(
      id: 'm2',
      title: 'Omeprazole',
      count: 2,
      times: const [DoseTime(hour: 9, minute: 0), DoseTime(hour: 21, minute: 0)],
      startDate: start,
    ),
    Medication(
      id: 'm3',
      title: 'Magnesium',
      count: 1,
      times: const [DoseTime(hour: 22, minute: 0)],
      startDate: start,
    ),
  ];
}

Future<void> capture(
  WidgetTester tester,
  Device device,
  String name,
  Widget child,
) async {
  tester.view.physicalSize = device.pixels;
  tester.view.devicePixelRatio = device.dpr;
  addTearDown(tester.view.reset);

  final key = GlobalKey();

  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: child,
      ),
    ),
  );

  // Advance past the entry animations with fixed pumps. pumpAndSettle would
  // never return here: several screens have deliberately looping animations.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pump(const Duration(milliseconds: 900));

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: device.dpr);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  final dir = Directory('.screenshots/${device.name}')
    ..createSync(recursive: true);
  final file = File('${dir.path}/$name.png')
    ..writeAsBytesSync(bytes!.buffer.asUint8List());

  // ignore: avoid_print
  print('wrote ${file.path} '
      '(${image.width}x${image.height})');
}

void main() {
  setUpAll(loadFonts);

  for (final device in devices) {
    group(device.name, () {
      testWidgets('01 results', (tester) async {
        await capture(
          tester,
          device,
          '01-results',
          ResultsScreen(report: buildReport()),
        );
      });

      testWidgets('02 history', (tester) async {
        await capture(
          tester,
          device,
          '02-history',
          Scaffold(
            body: HistoryScreen(
              reports: buildHistory(),
              onDelete: (_) async {},
            ),
          ),
        );
      });

      testWidgets('03 targets', (tester) async {
        const profile = UserProfile(
          uid: 'u1',
          displayName: 'Avo Sukiasyan',
          weightKg: 82,
          heightCm: 176,
          age: 36,
          country: 'Armenia',
        );
        final plan = const WellnessPlanner().build(
          l10n: lookupAppL10n(const Locale('en')),
          profile: profile,
        );
        await capture(
          tester,
          device,
          '03-targets',
          TargetsScreen(plan: plan, profile: profile),
        );
      });

      testWidgets('04 medicines', (tester) async {
        await capture(
          tester,
          device,
          '04-medicines',
          MedicationsScreen(
            medications: buildMedications(),
            onSave: (_) async {},
            onDelete: (_) async {},
            onToggleDose: (_, __, ___) async {},
            notificationsAllowed: true,
            onEnableNotifications: () async {},
          ),
        );
      });
    });
  }
}
