import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/medical_report.dart';
import 'history_store.dart';
import 'report_file_store.dart';
import 'app_log.dart';

class CloudHistoryService {
  CloudHistoryService({
    required this.local,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    ReportFileStore? fileStore,
  })  : _firestoreOverride = firestore,
        _storageOverride = storage,
        _fileStore = fileStore ?? ReportFileStore();

  final HistoryStore local;
  final FirebaseFirestore? _firestoreOverride;
  final FirebaseStorage? _storageOverride;
  final ReportFileStore _fileStore;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  FirebaseStorage get _storage => _storageOverride ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _reportsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('reports');
  }

  Future<void> ensureUserProfile({
    required String uid,
    required String? email,
    required String? displayName,
    required String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<MedicalReport>> loadReports(String uid) async {
    final snap = await _reportsRef(uid)
        .orderBy('uploadedAt', descending: true)
        .get();

    AppLog.cloud.success('Loaded reports', {'count': snap.docs.length});

    final reports = snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return MedicalReport.fromJson(data);
    }).toList();

    await local.save(reports);
    return reports;
  }

  Future<List<MedicalReport>> addReport({
    required String uid,
    required MedicalReport report,
  }) async {
    var toSave = report;

    if (report.storedFilePath != null && report.storedFilePath!.isNotEmpty) {
      try {
        final bytes = await _fileStore.readBytes(report.storedFilePath);
        if (bytes != null && bytes.isNotEmpty) {
          final ref = _storage
              .ref()
              .child('users')
              .child(uid)
              .child('reports')
              .child(report.id)
              .child(report.fileName);
          await ref.putData(
            bytes,
            SettableMetadata(
              contentType: report.fileName.toLowerCase().endsWith('.pdf')
                  ? 'application/pdf'
                  : 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            ),
          );
          final url = await ref.getDownloadURL();
          toSave = report.copyWith(cloudFileUrl: url);
        }
      } catch (e) {
        AppLog.storage.warn('Upload failed, keeping local copy', {'error': e});
      }
    }

    final payload = toSave.toJson()..remove('storedFilePath');
    await _reportsRef(uid).doc(toSave.id).set(payload, SetOptions(merge: true));
    AppLog.cloud.success(
      'Saved report',
      {'id': AppLog.redact(toSave.id), 'markers': toSave.markers.length},
    );
    return local.add(toSave);
  }

  Future<List<MedicalReport>> removeReport({
    required String uid,
    required MedicalReport report,
  }) async {
    await _reportsRef(uid).doc(report.id).delete();
    AppLog.cloud.success('Deleted report', {'id': AppLog.redact(report.id)});
    try {
      final listed = await _storage
          .ref()
          .child('users')
          .child(uid)
          .child('reports')
          .child(report.id)
          .listAll();
      for (final item in listed.items) {
        await item.delete();
      }
    } catch (e) {
      AppLog.storage.warn('Remote delete failed', {'error': e});
    }
    await _fileStore.delete(report.storedFilePath);
    return local.remove(report.id);
  }

  Future<List<MedicalReport>> migrateLocalToCloud(String uid) async {
    final localReports = local.load();
    for (final report in localReports) {
      await addReport(uid: uid, report: report);
    }
    return loadReports(uid);
  }
}
