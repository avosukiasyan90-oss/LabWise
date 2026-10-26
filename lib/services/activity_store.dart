import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_activity.dart';

/// Caches the days already read from Apple Health or Health Connect so the
/// calendar paints instantly and still has something to show offline.
class ActivityStore {
  ActivityStore(this._prefs);

  static const _key = 'daily_activity_v1';
  static const _maxDays = 400;

  final SharedPreferences _prefs;

  static Future<ActivityStore> create() async =>
      ActivityStore(await SharedPreferences.getInstance());

  Map<DateTime, DailyActivity> load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final days = <DateTime, DailyActivity>{};
      for (final entry in decoded) {
        final activity =
            DailyActivity.fromJson(entry as Map<String, dynamic>);
        days[activity.day] = activity;
      }
      return days;
    } catch (_) {
      return {};
    }
  }

  /// Merges freshly read days over the cache, newest kept.
  Future<Map<DateTime, DailyActivity>> merge(
    Map<DateTime, DailyActivity> fresh,
  ) async {
    final merged = {...load(), ...fresh};

    if (merged.length > _maxDays) {
      final ordered = merged.keys.toList()..sort((a, b) => b.compareTo(a));
      for (final key in ordered.skip(_maxDays)) {
        merged.remove(key);
      }
    }

    await _save(merged);
    return merged;
  }

  Future<void> _save(Map<DateTime, DailyActivity> days) async {
    final list = days.values.map((d) => d.toJson()).toList();
    await _prefs.setString(_key, jsonEncode(list));
  }

  Future<void> clear() async => _prefs.remove(_key);
}
