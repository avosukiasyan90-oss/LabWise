import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/medication.dart';

/// Saves the medication list on the device.
///
/// Reminders have to fire with no network, so this is the source of truth
/// rather than a cache of something remote.
class MedicationStore {
  MedicationStore(this._prefs);

  static const _key = 'medications_v1';

  final SharedPreferences _prefs;

  static Future<MedicationStore> create() async =>
      MedicationStore(await SharedPreferences.getInstance());

  List<Medication> load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Medication.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Medication> medications) async {
    await _prefs.setString(
      _key,
      jsonEncode(medications.map((m) => m.toJson()).toList()),
    );
  }

  Future<List<Medication>> upsert(Medication medication) async {
    final current = load();
    final index = current.indexWhere((m) => m.id == medication.id);
    if (index == -1) {
      current.add(medication);
    } else {
      current[index] = medication;
    }
    await save(current);
    return current;
  }

  Future<List<Medication>> remove(String id) async {
    final next = load().where((m) => m.id != id).toList();
    await save(next);
    return next;
  }

  Future<void> clear() async => _prefs.remove(_key);
}
