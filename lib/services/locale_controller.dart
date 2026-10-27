import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Languages LabWise ships with. English is the default.
enum AppLanguage {
  english('en'),
  russian('ru'),
  french('fr'),
  spanish('es'),
  german('de');

  const AppLanguage(this.code);

  final String code;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) => AppLanguage.values.firstWhere(
        (l) => l.code == code,
        orElse: () => AppLanguage.english,
      );
}

/// Holds the selected language and persists it across launches.
class LocaleController extends ChangeNotifier {
  LocaleController._(this._language);

  static const _key = 'app_language_v1';

  AppLanguage _language;

  AppLanguage get language => _language;

  Locale get locale => _language.locale;

  static Future<LocaleController> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return LocaleController._(AppLanguage.fromCode(prefs.getString(_key)));
    } catch (_) {
      return LocaleController._(AppLanguage.english);
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, language.code);
    } catch (_) {
      // A failed write only means the choice resets next launch.
    }
  }
}
