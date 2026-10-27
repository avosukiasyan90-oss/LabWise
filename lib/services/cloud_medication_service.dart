import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medication.dart';
import 'app_log.dart';
import 'medication_store.dart';

/// Keeps the medication list in Firestore so it survives a reinstall, while
/// the device copy stays the source of truth for firing reminders offline.
class CloudMedicationService {
  CloudMedicationService({
    required this.local,
    FirebaseFirestore? firestore,
  }) : _firestoreOverride = firestore;

  final MedicationStore local;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection('users').doc(uid).collection('medications');

  /// Pulls the cloud list and writes it over the local cache.
  ///
  /// Anything only on this device is pushed up first, so a medicine added
  /// while offline is not lost when the cloud copy arrives.
  Future<List<Medication>> load(String uid) async {
    final cached = local.load();

    try {
      final snap = await _ref(uid).get();
      final remote = snap.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Medication.fromJson(data);
      }).toList();

      final remoteIds = remote.map((m) => m.id).toSet();
      final localOnly = cached.where((m) => !remoteIds.contains(m.id));
      for (final medication in localOnly) {
        await _write(uid, medication);
      }

      final merged = [...remote, ...localOnly];
      await local.save(merged);
      AppLog.cloud.success('Loaded medicines', {'count': merged.length});
      return merged;
    } catch (e) {
      AppLog.cloud.warn('Medicine sync failed, using device copy', {
        'error': e,
      });
      return cached;
    }
  }

  Future<List<Medication>> save({
    required String uid,
    required Medication medication,
  }) async {
    // Local first: reminders must keep working even with no connection, and
    // awaiting a Firestore write while offline never resolves.
    final next = await local.upsert(medication);
    unawaited(_write(uid, medication));
    return next;
  }

  Future<List<Medication>> remove({
    required String uid,
    required String id,
  }) async {
    final next = await local.remove(id);
    unawaited(_delete(uid, id));
    return next;
  }

  Future<void> _write(String uid, Medication medication) async {
    try {
      final payload = medication.toJson()..remove('id');
      await _ref(uid).doc(medication.id).set(payload, SetOptions(merge: true));
    } catch (e) {
      AppLog.cloud.warn('Medicine not synced', {'error': e});
    }
  }

  Future<void> _delete(String uid, String id) async {
    try {
      await _ref(uid).doc(id).delete();
    } catch (e) {
      AppLog.cloud.warn('Medicine not removed remotely', {'error': e});
    }
  }
}

/// Fire-and-forget without tripping the unawaited_futures lint.
void unawaited(Future<void> future) {
  future.ignore();
}
