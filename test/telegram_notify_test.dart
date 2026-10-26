import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/config/app_secrets.dart';
import 'package:healthy_project/models/signup_report.dart';
import 'package:healthy_project/services/telegram_notify_service.dart';

void main() {
  test('posts to the LabWiseApp channel', () {
    expect(AppSecrets.telegramChannel, '@LabWiseApp');
  });

  group('message contents', () {
    final full = SignupReport(
      uid: 'EyzGabc123def456',
      provider: 'google',
      firstName: 'Avo',
      surname: 'Suqiasyan',
      email: 'avo.sukiasyan90@gmail.com',
      emailVerified: true,
      phoneNumber: '+37493078780',
      photoUrl: 'https://lh3.googleusercontent.com/a/photo',
      createdAt: DateTime(2026, 10, 26, 19, 57),
      platform: 'iOS',
      osVersion: 'iOS 26.1',
      deviceModel: 'iPhone17,2',
      appVersion: '1.0.0 (1)',
      locale: 'en-US',
      timeZone: '+04 (UTC+04:00)',
    );

    test('includes every identity field the provider gave us', () {
      final text = TelegramNotifyService.buildMessage(full);

      expect(text, contains('New LabWise Health signup'));
      expect(text, contains('Name: Avo'));
      expect(text, contains('Surname: Suqiasyan'));
      expect(text, contains('Full name: Avo Suqiasyan'));
      expect(text, contains('Email: avo.sukiasyan90@gmail.com'));
      expect(text, contains('Email verified: yes'));
      expect(text, contains('Phone: +37493078780'));
      expect(text, contains('Signed up with: google'));
      expect(text, contains('UID: EyzGabc123def456'));
    });

    test('includes the device and build it came from', () {
      final text = TelegramNotifyService.buildMessage(full);

      expect(text, contains('Device: iPhone17,2'));
      expect(text, contains('Platform: iOS'));
      expect(text, contains('OS: iOS 26.1'));
      expect(text, contains('App version: 1.0.0 (1)'));
      expect(text, contains('Language: en-US'));
      expect(text, contains('Time zone: +04 (UTC+04:00)'));
    });

    test('omits fields the provider withheld rather than printing dashes', () {
      const sparse = SignupReport(
        uid: 'abc',
        provider: 'apple',
        firstName: 'Avo',
      );
      final text = TelegramNotifyService.buildMessage(sparse);

      expect(text, contains('Name: Avo'));
      expect(text, contains('Signed up with: apple'));
      expect(text, isNot(contains('Email:')));
      expect(text, isNot(contains('Phone:')));
      expect(text, isNot(contains('Device:')));
      expect(text, isNot(contains('—')));
    });

    test('notes when an email is unverified', () {
      const unverified = SignupReport(
        uid: 'abc',
        provider: 'apple',
        email: 'private@privaterelay.appleid.com',
      );
      expect(
        TelegramNotifyService.buildMessage(unverified),
        contains('Email verified: no'),
      );
    });

    test('does not leave blank runs where fields were dropped', () {
      const sparse = SignupReport(uid: 'abc', provider: 'apple');
      final text = TelegramNotifyService.buildMessage(sparse);

      expect(text, isNot(contains('\n\n\n')));
      expect(text.trimRight(), text);
      expect(text.split('\n').last, 'UID: abc');
    });

    test('skips the duplicate full name when there is no surname', () {
      const single = SignupReport(
        uid: 'abc',
        provider: 'google',
        firstName: 'Avo',
      );
      expect(
        TelegramNotifyService.buildMessage(single),
        isNot(contains('Full name:')),
      );
    });
  });

  group('splitting the provider display name', () {
    test('splits first and last', () {
      final (first, last) =
          TelegramNotifyService.splitDisplayName('Avo Suqiasyan');
      expect(first, 'Avo');
      expect(last, 'Suqiasyan');
    });

    test('keeps multi-word surnames together', () {
      final (first, last) =
          TelegramNotifyService.splitDisplayName('Avo van der Suqiasyan');
      expect(first, 'Avo');
      expect(last, 'van der Suqiasyan');
    });

    test('handles a single name and a missing one', () {
      expect(TelegramNotifyService.splitDisplayName('Avo'), ('Avo', ''));
      expect(TelegramNotifyService.splitDisplayName(null), ('', ''));
      expect(TelegramNotifyService.splitDisplayName('   '), ('', ''));
    });
  });
}
