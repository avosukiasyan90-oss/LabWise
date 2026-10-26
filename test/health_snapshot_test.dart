import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/models/lab_marker.dart';
import 'package:healthy_project/models/medical_report.dart';
import 'package:healthy_project/models/user_profile.dart';
import 'package:healthy_project/services/health_snapshot.dart';

LabMarker marker({required MarkerStatus status, String id = 'x'}) => LabMarker(
      id: id,
      name: id,
      unit: '',
      status: status,
      value: 1,
    );

MedicalReport report({
  required List<LabMarker> markers,
  DateTime? at,
  String id = 'r1',
}) =>
    MedicalReport(
      id: id,
      fileName: '$id.pdf',
      uploadedAt: at ?? DateTime(2026, 5, 16),
      summary: '',
      whatToDo: const [],
      markers: markers,
    );

void main() {
  const healthy = UserProfile(uid: 'u', weightKg: 68, heightCm: 176, age: 30);
  const heavy = UserProfile(uid: 'u', weightKg: 95, heightCm: 176, age: 36);
  const slightlyOver =
      UserProfile(uid: 'u', weightKg: 82, heightCm: 176, age: 36);
  const blank = UserProfile(uid: 'u');

  group('with nothing to go on', () {
    test('says so rather than guessing', () {
      final snapshot = HealthSnapshot.of(profile: blank, reports: const []);

      expect(snapshot.tone, HealthTone.unknown);
      expect(snapshot.isEmpty, isTrue);
      expect(snapshot.hasBmi, isFalse);
      expect(snapshot.hasReport, isFalse);
    });

    test('lists which details are missing', () {
      final snapshot = HealthSnapshot.of(profile: blank, reports: const []);
      expect(snapshot.missingProfileFields, ['weight', 'height', 'age']);
    });
  });

  group('from body details alone', () {
    test('a healthy range with no report reads as good', () {
      final snapshot = HealthSnapshot.of(profile: healthy, reports: const []);

      expect(snapshot.band, BmiBand.healthy);
      expect(snapshot.tone, HealthTone.good);
      expect(snapshot.bmi, closeTo(22.0, 0.1));
    });

    test('above range is worth watching', () {
      final snapshot =
          HealthSnapshot.of(profile: slightlyOver, reports: const []);
      expect(snapshot.band, BmiBand.above);
      expect(snapshot.tone, HealthTone.watch);
    });

    test('well above range needs attention on its own', () {
      final snapshot = HealthSnapshot.of(profile: heavy, reports: const []);
      expect(snapshot.band, BmiBand.wellAbove);
      expect(snapshot.tone, HealthTone.attention);
    });

    test('under range is also worth watching', () {
      final snapshot = HealthSnapshot.of(
        profile: const UserProfile(uid: 'u', weightKg: 48, heightCm: 176),
        reports: const [],
      );
      expect(snapshot.band, BmiBand.under);
      expect(snapshot.tone, HealthTone.watch);
    });
  });

  group('from reports', () {
    test('a clean report with a healthy body reads as good', () {
      final snapshot = HealthSnapshot.of(
        profile: healthy,
        reports: [
          report(markers: List.filled(8, marker(status: MarkerStatus.normal))),
        ],
      );

      expect(snapshot.tone, HealthTone.good);
      expect(snapshot.flagged, 0);
      expect(snapshot.tracked, 8);
    });

    test('one flagged value downgrades an otherwise healthy reading', () {
      final snapshot = HealthSnapshot.of(
        profile: healthy,
        reports: [
          report(markers: [
            marker(status: MarkerStatus.high),
            marker(status: MarkerStatus.normal),
          ]),
        ],
      );

      expect(snapshot.tone, HealthTone.watch);
      expect(snapshot.flagged, 1);
    });

    test('three or more flagged values need attention', () {
      final snapshot = HealthSnapshot.of(
        profile: healthy,
        reports: [
          report(markers: [
            marker(status: MarkerStatus.high),
            marker(status: MarkerStatus.low),
            marker(status: MarkerStatus.high),
            marker(status: MarkerStatus.normal),
          ]),
        ],
      );

      expect(snapshot.tone, HealthTone.attention);
      expect(snapshot.flagged, 3);
    });

    test('only the newest report counts', () {
      final snapshot = HealthSnapshot.of(
        profile: healthy,
        reports: [
          report(
            id: 'old',
            at: DateTime(2025, 1, 1),
            markers: List.filled(5, marker(status: MarkerStatus.high)),
          ),
          report(
            id: 'new',
            at: DateTime(2026, 5, 16),
            markers: [marker(status: MarkerStatus.normal)],
          ),
        ],
      );

      expect(snapshot.flagged, 0);
      expect(snapshot.tracked, 1);
      expect(snapshot.tone, HealthTone.good);
      expect(snapshot.reportCount, 2);
      expect(snapshot.lastReportAt, DateTime(2026, 5, 16));
    });

    test('a clean report does not cancel out a well-above BMI', () {
      final snapshot = HealthSnapshot.of(
        profile: heavy,
        reports: [
          report(markers: List.filled(6, marker(status: MarkerStatus.normal))),
        ],
      );
      expect(snapshot.tone, HealthTone.attention);
    });

    test('a report alone is enough when the profile is empty', () {
      final snapshot = HealthSnapshot.of(
        profile: blank,
        reports: [report(markers: [marker(status: MarkerStatus.normal)])],
      );

      expect(snapshot.isEmpty, isFalse);
      expect(snapshot.tone, HealthTone.good);
      expect(snapshot.hasBmi, isFalse);
    });
  });

  test('band boundaries fall on the documented numbers', () {
    expect(HealthSnapshot.bandFor(18.4), BmiBand.under);
    expect(HealthSnapshot.bandFor(18.5), BmiBand.healthy);
    expect(HealthSnapshot.bandFor(24.9), BmiBand.healthy);
    expect(HealthSnapshot.bandFor(25.0), BmiBand.above);
    expect(HealthSnapshot.bandFor(29.9), BmiBand.above);
    expect(HealthSnapshot.bandFor(30.0), BmiBand.wellAbove);
  });
}
