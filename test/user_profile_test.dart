import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/models/user_profile.dart';

void main() {
  test('splits Google display name into name and surname', () {
    const profile = UserProfile(
      uid: 'u1',
      displayName: 'Avetik Sukiasyan',
      email: 'a@example.com',
    );

    expect(profile.firstName, 'Avetik');
    expect(profile.surname, 'Sukiasyan');
  });

  test('computes BMI only when weight and height are present', () {
    const withBoth = UserProfile(uid: 'u1', weightKg: 80, heightCm: 180);
    const weightOnly = UserProfile(uid: 'u1', weightKg: 80);

    expect(withBoth.bmi, closeTo(24.69, 0.01));
    expect(weightOnly.bmi, isNull);
  });

  test('round-trips health details through JSON', () {
    final profile = UserProfile(
      uid: 'u1',
      email: 'a@example.com',
      displayName: 'Avetik Sukiasyan',
      weightKg: 78.5,
      heightCm: 176,
      age: 36,
      country: 'Armenia',
      onboardedAt: DateTime.utc(2026, 10, 23),
    );

    final restored = UserProfile.fromJson('u1', profile.toJson());

    expect(restored.weightKg, 78.5);
    expect(restored.heightCm, 176);
    expect(restored.age, 36);
    expect(restored.country, 'Armenia');
    expect(restored.hasOnboarded, isTrue);
  });

  test('copyWith can clear optional health fields', () {
    const profile = UserProfile(
      uid: 'u1',
      weightKg: 80,
      heightCm: 180,
      age: 40,
      country: 'Armenia',
    );

    final cleared = profile.copyWith(clearWeight: true, clearCountry: true);

    expect(cleared.weightKg, isNull);
    expect(cleared.country, isNull);
    expect(cleared.heightCm, 180);
    expect(cleared.age, 40);
  });
}
