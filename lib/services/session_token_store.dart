import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists lightweight session metadata + last Firebase ID token locally
/// so the app can restore login quickly after relaunch.
class SessionTokenStore {
  SessionTokenStore(this._prefs);

  static const _uidKey = 'auth_uid_v1';
  static const _emailKey = 'auth_email_v1';
  static const _nameKey = 'auth_display_name_v1';
  static const _tokenKey = 'auth_id_token_v1';
  static const _savedAtKey = 'auth_token_saved_at_v1';

  final SharedPreferences _prefs;

  static Future<SessionTokenStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionTokenStore(prefs);
  }

  String? get uid => _prefs.getString(_uidKey);
  String? get email => _prefs.getString(_emailKey);
  String? get displayName => _prefs.getString(_nameKey);
  String? get idToken => _prefs.getString(_tokenKey);

  bool get hasSavedSession =>
      (uid?.isNotEmpty ?? false) && (idToken?.isNotEmpty ?? false);

  Future<void> saveFromUser(User user, {String? idToken}) async {
    await _prefs.setString(_uidKey, user.uid);
    await _prefs.setString(_emailKey, user.email ?? '');
    await _prefs.setString(_nameKey, user.displayName ?? '');
    if (idToken != null && idToken.isNotEmpty) {
      await _prefs.setString(_tokenKey, idToken);
      await _prefs.setInt(
        _savedAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<void> saveIdToken(String token) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setInt(_savedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clear() async {
    await _prefs.remove(_uidKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_savedAtKey);
  }
}
