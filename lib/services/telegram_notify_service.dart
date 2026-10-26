import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_secrets.dart';
import '../models/signup_report.dart';
import 'app_log.dart';

class TelegramNotifyService {
  TelegramNotifyService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Posts a new-signup notice to https://t.me/LabWiseApp
  ///
  /// Everything the identity provider gave us is included, along with the
  /// device and build it came from. Note this is a real disclosure of
  /// personal data to a third party and has to be declared on both app
  /// stores' privacy forms.
  Future<bool> notifyNewSignup(SignupReport report) async {
    if (!AppSecrets.hasTelegramBot) {
      AppLog.net.warn('Telegram skipped: no bot token configured');
      return false;
    }

    final text = buildMessage(report);

    final uri = Uri.parse(
      'https://api.telegram.org/bot${AppSecrets.telegramBotToken}/sendMessage',
    );

    AppLog.net.request('POST', uri);
    final started = DateTime.now();

    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': AppSecrets.telegramChannel,
          'text': text,
          'disable_web_page_preview': true,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        AppLog.net.response(
          response.statusCode,
          uri,
          took: DateTime.now().difference(started),
        );
        return true;
      }
      AppLog.net.response(
        response.statusCode,
        uri,
        took: DateTime.now().difference(started),
      );
      return false;
    } catch (e) {
      AppLog.net.error('Telegram notify error', error: e);
      return false;
    }
  }

  /// Formats the channel post. Separated from sending so it can be checked
  /// without a network.
  @visibleForTesting
  static String buildMessage(SignupReport r) {
    String line(String label, Object? value) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return '';
      return '$label: $text';
    }

    final sections = <String>[
      '🆕 New LabWise Health signup',
      '',
      line('Name', r.firstName),
      line('Surname', r.surname),
      if (r.fullName.isNotEmpty && r.fullName != r.firstName)
        line('Full name', r.fullName),
      line('Email', r.email),
      if (r.email != null) line('Email verified', r.emailVerified ? 'yes' : 'no'),
      line('Phone', r.phoneNumber),
      line('Signed up with', r.provider),
      line('Photo', r.photoUrl),
      '',
      line('Account created', r.createdAt?.toLocal().toString()),
      line('Device', r.deviceModel),
      line('Platform', r.platform),
      line('OS', r.osVersion),
      line('App version', r.appVersion),
      line('Language', r.locale),
      line('Time zone', r.timeZone),
      '',
      line('UID', r.uid),
    ];

    // Drop the blank separators that ended up next to omitted fields.
    final kept = <String>[];
    for (final part in sections) {
      if (part.isEmpty && (kept.isEmpty || kept.last.isEmpty)) continue;
      kept.add(part);
    }
    while (kept.isNotEmpty && kept.last.isEmpty) {
      kept.removeLast();
    }

    return kept.join('\n');
  }

  static (String firstName, String surname) splitDisplayName(String? displayName) {
    final parts = (displayName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return ('', '');
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }
}
