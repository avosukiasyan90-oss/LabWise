import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/l10n/app_localizations.dart';
import 'package:healthy_project/models/lab_marker.dart';
import 'package:healthy_project/models/medical_report.dart';
import 'package:healthy_project/models/user_profile.dart';
import 'package:healthy_project/services/wellness_planner.dart';

void main() {
  const planner = WellnessPlanner();
  final l10n = lookupAppL10n(const Locale('en'));

  MedicalReport reportWith(List<LabMarker> markers) => MedicalReport(
        id: 'r1',
        fileName: 'lab.pdf',
        uploadedAt: DateTime(2026, 10, 1),
        summary: '',
        whatToDo: const [],
        markers: markers,
      );

  test('asks for the profile when height and weight are missing', () {
    final plan = planner.build(l10n: l10n, profile: const UserProfile(uid: 'u1'));

    expect(plan.isPersonalized, isFalse);
    expect(plan.missingFields, containsAll(['weight', 'height', 'age']));
    expect(plan.mealWindows, isEmpty);
  });

  test('builds targets and a schedule from height, weight, and age', () {
    final plan = planner.build(
      l10n: l10n,
      profile: const UserProfile(
        uid: 'u1',
        displayName: 'Avetik Sukiasyan',
        weightKg: 80,
        heightCm: 180,
        age: 36,
      ),
    );

    expect(plan.isPersonalized, isTrue);
    expect(plan.bmi, closeTo(24.7, 0.1));
    expect(plan.bmiLabel, 'Healthy range');
    expect(plan.dailyCalories, greaterThan(1800));
    expect(plan.waterLitres, closeTo(2.6, 0.1));
    expect(plan.stepGoal, greaterThan(5000));
    expect(plan.eatingWindow, '08:00 – 20:00');
    expect(plan.mealWindows, isNotEmpty);
    expect(plan.activities, isNotEmpty);
    expect(plan.headline, contains('Avetik'));
  });

  test('shifts to joint-friendly activity and fewer calories at high BMI', () {
    final high = planner.build(
      l10n: l10n,
      profile: const UserProfile(
        uid: 'u1',
        weightKg: 110,
        heightCm: 170,
        age: 45,
      ),
    );
    final healthy = planner.build(
      l10n: l10n,
      profile: const UserProfile(
        uid: 'u1',
        weightKg: 70,
        heightCm: 170,
        age: 45,
      ),
    );

    expect(high.bmiLabel, 'Well above range');
    expect(high.eatingWindow, '09:00 – 19:00');
    expect(
      high.activities.map((a) => a.name),
      contains('Swimming or water aerobics'),
    );
    expect(high.dailyCalories, lessThan(healthy.dailyCalories! + 200));
  });

  test('adds mobility work for older users', () {
    final plan = planner.build(
      l10n: l10n,
      profile: const UserProfile(
        uid: 'u1',
        weightKg: 70,
        heightCm: 170,
        age: 68,
      ),
    );

    expect(
      plan.activities.map((a) => a.name),
      contains('Balance and mobility'),
    );
  });

  test('turns flagged markers into plan notes', () {
    final plan = planner.build(
      l10n: l10n,
      profile: const UserProfile(
        uid: 'u1',
        weightKg: 80,
        heightCm: 180,
        age: 36,
      ),
      reports: [
        reportWith(const [
          LabMarker(
            id: 'ldl',
            name: 'LDL',
            unit: 'mmol/L',
            status: MarkerStatus.high,
            value: 4.4,
          ),
        ]),
      ],
    );

    expect(plan.reportNotes, isNotEmpty);
    expect(plan.reportNotes.first.toLowerCase(), contains('cholesterol'));
  });
}
