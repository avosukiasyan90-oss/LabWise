import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/medical_report.dart';

class HistoryStore {
  HistoryStore(this._prefs);

  static const _key = 'medical_report_history_v1';
  final SharedPreferences _prefs;

  static Future<HistoryStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return HistoryStore(prefs);
  }

  List<MedicalReport> load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final reports = list
          .map((e) => MedicalReport.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      return reports;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<MedicalReport> reports) async {
    final encoded = jsonEncode(reports.map((r) => r.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }

  Future<List<MedicalReport>> add(MedicalReport report) async {
    final current = load();
    final next = [report, ...current.where((r) => r.id != report.id)];
    await save(next);
    return next;
  }

  Future<List<MedicalReport>> remove(String id) async {
    final next = load().where((r) => r.id != id).toList();
    await save(next);
    return next;
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
