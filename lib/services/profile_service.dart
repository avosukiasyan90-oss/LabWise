import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'app_log.dart';

/// Reads and writes `users/{uid}` profile data, with a local cache so the
/// profile screen still renders when offline.
class ProfileService {
  ProfileService({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  static const _cacheKeyPrefix = 'user_profile_v1_';

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Identity comes from Google and always overwrites the stored copy.
  Future<UserProfile> loadForUser(User user) async {
    final cached = await _readCache(user.uid);

    try {
      final snap = await _doc(user.uid).get();
      final data = snap.data() ?? <String, dynamic>{};
      final profile = UserProfile.fromJson(user.uid, {
        ...data,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'onboardedAt': _timestampToIso(data['onboardedAt']),
      });
      await _writeCache(profile);
      AppLog.profile.success('Loaded', {'uid': AppLog.redact(user.uid)});
      return profile;
    } catch (e) {
      AppLog.profile.warn('Cloud load failed, using cache', {'error': e});
      if (cached != null) {
        return cached.copyWith(
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      }
      return UserProfile(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    }
  }

  /// Saves the editable health fields plus the Google identity snapshot.
  Future<UserProfile> save(UserProfile profile) async {
    final toStore = profile.onboardedAt == null
        ? profile.copyWith(onboardedAt: DateTime.now())
        : profile;

    await _writeCache(toStore);
    await _doc(toStore.uid).set({
      'email': toStore.email,
      'displayName': toStore.displayName,
      'photoUrl': toStore.photoUrl,
      'weightKg': toStore.weightKg,
      'heightCm': toStore.heightCm,
      'age': toStore.age,
      'country': toStore.country,
      'onboardedAt': toStore.onboardedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(toStore.onboardedAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    AppLog.profile.success('Saved', {
      'weight': toStore.weightKg,
      'height': toStore.heightCm,
      'age': toStore.age,
    });
    return toStore;
  }

  /// Marks setup as seen without storing any health values.
  Future<UserProfile> markOnboarded(UserProfile profile) async {
    if (profile.hasOnboarded) return profile;
    return save(profile);
  }

  static String? _timestampToIso(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    return value.toString();
  }

  Future<UserProfile?> _readCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_cacheKeyPrefix$uid');
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(uid, json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_cacheKeyPrefix${profile.uid}',
        jsonEncode(profile.toJson()),
      );
    } catch (_) {
      // Cache is best-effort only.
    }
  }
}
