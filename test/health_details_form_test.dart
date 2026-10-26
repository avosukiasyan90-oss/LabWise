import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/l10n/app_localizations.dart';
import 'package:healthy_project/models/user_profile.dart';
import 'package:healthy_project/widgets/health_details_form.dart';

void main() {
  Widget host(UserProfile profile) => MaterialApp(
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: HealthDetailsForm(
            profile: profile,
            onChanged: ({weightKg, heightCm, age, country}) {},
          ),
        ),
      );

  testWidgets('shows values saved during sign-up setup', (tester) async {
    const empty = UserProfile(uid: 'u1');
    await tester.pumpWidget(host(empty));

    expect(find.text('78'), findsNothing);

    const saved = UserProfile(
      uid: 'u1',
      weightKg: 78,
      heightCm: 176,
      age: 36,
      country: 'Armenia',
    );
    await tester.pumpWidget(host(saved));
    await tester.pump();

    expect(find.text('78'), findsOneWidget);
    expect(find.text('176'), findsOneWidget);
    expect(find.text('36'), findsOneWidget);
    expect(find.text('Armenia'), findsOneWidget);
  });

  testWidgets('keeps typed input when the profile is unchanged', (tester) async {
    const profile = UserProfile(uid: 'u1');
    await tester.pumpWidget(host(profile));

    await tester.enterText(find.byType(TextField).first, '82');
    await tester.pumpWidget(host(profile));

    expect(find.text('82'), findsOneWidget);
  });
}
