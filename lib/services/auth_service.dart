import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/google_oauth.dart';
import 'session_token_store.dart';
import 'telegram_notify_service.dart';
import '../models/signup_report.dart';
import 'app_log.dart';
import 'device_context.dart';

enum AuthProviderKind { google, apple }

class AuthSignInResult {
  const AuthSignInResult({
    required this.credential,
    required this.isNewUser,
    required this.provider,
  });

  final UserCredential credential;
  final bool isNewUser;
  final AuthProviderKind provider;

  User? get user => credential.user;
}

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    SessionTokenStore? sessionStore,
    TelegramNotifyService? telegramNotify,
  })  : _authOverride = auth,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        // ignore: prefer_initializing_formals
        _sessionStore = sessionStore,
        _telegram = telegramNotify ?? TelegramNotifyService();

  final FirebaseAuth? _authOverride;
  final GoogleSignIn _googleSignIn;
  final SessionTokenStore? _sessionStore;
  final TelegramNotifyService _telegram;
  bool _googleReady = false;
  StreamSubscription<User?>? _tokenSub;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => currentUser != null;

  Future<bool> get isAppleSignInAvailable async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      return false;
    }
    try {
      return await SignInWithApple.isAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<void> ensureGoogleInitialized({
    String? clientId,
    String? serverClientId,
  }) async {
    if (_googleReady) return;
    await _googleSignIn.initialize(
      clientId: clientId ??
          (defaultTargetPlatform == TargetPlatform.iOS
              ? GoogleOAuthConfig.iosClientId
              : null),
      serverClientId: serverClientId ?? GoogleOAuthConfig.serverClientId,
    );
    _googleReady = true;
  }

  /// Restores the saved session on launch and keeps it alive indefinitely.
  ///
  /// Firebase stores the refresh token in the platform keychain, so the session
  /// survives restarts and only ends when the user signs out explicitly.
  Future<User?> restoreSession({
    String? clientId,
    String? serverClientId,
  }) async {
    if (kIsWeb) {
      try {
        await _auth.setPersistence(Persistence.LOCAL);
      } catch (e) {
        AppLog.auth.debug('Persistence not settable on this platform');
      }
    }

    startTokenAutoRefresh();

    var user = _auth.currentUser;
    if (user != null) {
      // Cached token first so an offline launch still stays signed in.
      await _persistToken(user, forceRefresh: false);
      unawaited(_persistToken(user, forceRefresh: true));
      return user;
    }

    // Only Google needs a silent re-auth path; Apple restores from Firebase.
    try {
      await ensureGoogleInitialized(
        clientId: clientId,
        serverClientId: serverClientId,
      );
      final lightweight = _googleSignIn.attemptLightweightAuthentication();
      final googleUser = lightweight == null ? null : await lightweight;
      final idToken = googleUser?.authentication.idToken;
      if (idToken != null && idToken.isNotEmpty) {
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        final result = await _auth.signInWithCredential(credential);
        user = result.user;
        if (user != null) await _persistToken(user, forceRefresh: false);
      }
    } catch (e) {
      AppLog.auth.debug('Lightweight Google restore unavailable', {'error': e});
    }

    return _auth.currentUser;
  }

  /// Mirrors every Firebase token refresh into the local session store.
  void startTokenAutoRefresh() {
    _tokenSub ??= _auth.idTokenChanges().listen(
      (user) async {
        if (user == null) return;
        await _persistToken(user, forceRefresh: false);
      },
      onError: (Object e) {
        // Never sign the user out because a refresh attempt failed.
        AppLog.auth.warn('Token stream error, session kept', {'error': e});
      },
    );
  }

  Future<void> dispose() async {
    await _tokenSub?.cancel();
    _tokenSub = null;
  }

  /// Returns a usable Firebase ID token, refreshing it when possible.
  Future<String?> getValidIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return _sessionStore?.idToken;
    try {
      final token = await user.getIdToken(forceRefresh);
      if (token != null && token.isNotEmpty) {
        await _sessionStore?.saveIdToken(token);
        return token;
      }
    } catch (e) {
      AppLog.auth.warn('Token fetch failed, cached token kept', {'error': e});
    }
    return _sessionStore?.idToken;
  }

  Future<AuthSignInResult> signInWithGoogle({
    String? clientId,
    String? serverClientId,
  }) async {
    final credential = await _googleCredential(
      clientId: clientId,
      serverClientId: serverClientId,
    );
    return _completeSignIn(
      credential: credential,
      provider: AuthProviderKind.google,
    );
  }

  Future<AuthCredential> _googleCredential({
    String? clientId,
    String? serverClientId,
  }) async {
    await ensureGoogleInitialized(
      clientId: clientId,
      serverClientId: serverClientId,
    );

    if (!_googleSignIn.supportsAuthenticate()) {
      throw StateError(
        'Google Sign-In is not supported on this platform build.',
      );
    }

    AppLog.auth.info('Requesting Google credential');

    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        AppLog.auth.info('Google sign-in cancelled by the user');
        throw StateError('Sign-in was canceled.');
      }
      AppLog.auth.error('Google credential refused', data: {
        'code': e.code.name,
        'detail': e.description ?? '-',
      });
      throw StateError('Google Sign-In failed: ${e.description ?? e.code.name}');
    }

    final idToken = googleUser.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      AppLog.auth.error('Google returned no ID token');
      throw StateError(
        'Google did not return an ID token. '
        'Enable Google in Firebase Authentication and ensure the Web client ID is set.',
      );
    }

    return GoogleAuthProvider.credential(idToken: idToken);
  }

  Future<AuthSignInResult> signInWithApple() async {
    final apple = await _appleCredential();
    return _completeSignIn(
      credential: apple.credential,
      provider: AuthProviderKind.apple,
      fallbackDisplayName: apple.displayName,
    );
  }

  Future<({AuthCredential credential, String? displayName})>
      _appleCredential() async {
    final rawNonce = _randomNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        AppLog.auth.info('Apple sign-in cancelled by the user');
        throw StateError('Sign-in was canceled.');
      }
      AppLog.auth.error('Apple credential refused', data: {
        'code': e.code.name,
        'detail': e.message,
      });
      throw StateError('Apple Sign-In failed: ${e.message}');
    }

    final identityToken = appleCredential.identityToken;
    if (identityToken == null || identityToken.isEmpty) {
      throw StateError(
        'Apple did not return an identity token. '
        'Enable Apple in Firebase Authentication and add the Sign in with Apple capability.',
      );
    }

    final credential = OAuthProvider('apple.com').credential(
      idToken: identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );

    // Apple sends the name only on the very first authorization.
    final appleName = [
      appleCredential.givenName ?? '',
      appleCredential.familyName ?? '',
    ].where((p) => p.trim().isNotEmpty).join(' ').trim();

    return (
      credential: credential,
      displayName: appleName.isEmpty ? null : appleName,
    );
  }

  Future<AuthSignInResult> _completeSignIn({
    required AuthCredential credential,
    required AuthProviderKind provider,
    String? fallbackDisplayName,
  }) async {
    AppLog.auth.info('Signing in', {'provider': provider.name});
    try {
      final result = await _auth.signInWithCredential(credential);
      final signedIn = result.user;
      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (signedIn != null) {
        var user = signedIn;
        final currentName = user.displayName?.trim() ?? '';
        if (currentName.isEmpty &&
            fallbackDisplayName != null &&
            fallbackDisplayName.isNotEmpty) {
          try {
            await user.updateDisplayName(fallbackDisplayName);
            await user.reload();
            user = _auth.currentUser ?? user;
          } catch (e) {
            AppLog.auth.warn('Display name not saved', {'error': e});
          }
        }

        AppLog.auth.success('Signed in', {
          'provider': provider.name,
          'uid': AppLog.redact(user.uid),
          'newUser': isNewUser,
        });

        startTokenAutoRefresh();
        await _persistToken(user, forceRefresh: true);

        if (isNewUser) {
          await _notifyTelegramNewSignup(
            user,
            fallbackDisplayName: fallbackDisplayName,
            provider: provider,
          );
        }
      }

      return AuthSignInResult(
        credential: result,
        isNewUser: isNewUser,
        provider: provider,
      );
    } on FirebaseAuthException catch (e) {
      // The same person signing in with their other provider: Firebase keeps
      // one account per email address, so attach the new credential to the
      // account that already exists rather than refusing.
      if (e.code == 'account-exists-with-different-credential') {
        return _linkToExistingAccount(error: e, attempted: provider);
      }

      if (e.code == 'operation-not-allowed') {
        AppLog.auth.error('Provider not enabled', data: {
          'provider': provider.name,
        });
        throw StateError(
          '${_providerLabel(provider)} sign-in is not enabled for this Firebase '
          'project. Turn it on under Authentication, Sign-in method.',
        );
      }

      AppLog.auth.error('Sign-in rejected', data: {'code': e.code});
      throw StateError(e.message ?? 'Firebase Auth failed (${e.code}).');
    }
  }

  static String _providerLabel(AuthProviderKind provider) =>
      switch (provider) {
        AuthProviderKind.google => 'Google',
        AuthProviderKind.apple => 'Apple',
      };

  /// Attaches a second sign-in method to the account that already owns this
  /// email, so signing up with Google and later using Apple lands on one
  /// account instead of two.
  ///
  /// Only works when both providers report the same address. Apple's Hide My
  /// Email returns a privaterelay.appleid.com alias, which can never match a
  /// Google address, so that case stays a separate account by design.
  Future<AuthSignInResult> _linkToExistingAccount({
    required FirebaseAuthException error,
    required AuthProviderKind attempted,
  }) async {
    final pending = error.credential;
    if (pending == null) {
      throw StateError(
        error.message ?? 'This email already uses a different sign-in method.',
      );
    }

    // There are only two providers, so the account must use the other one.
    final existing = attempted == AuthProviderKind.apple
        ? AuthProviderKind.google
        : AuthProviderKind.apple;

    AppLog.auth.info('Email already registered, linking providers', {
      'attempted': attempted.name,
      'existing': existing.name,
    });

    final AuthCredential existingCredential;
    String? fallbackName;
    if (existing == AuthProviderKind.google) {
      existingCredential = await _googleCredential();
    } else {
      final apple = await _appleCredential();
      existingCredential = apple.credential;
      fallbackName = apple.displayName;
    }

    final result = await _auth.signInWithCredential(existingCredential);
    final user = result.user;
    if (user == null) {
      throw StateError('Could not open the existing account.');
    }

    try {
      await user.linkWithCredential(pending);
      AppLog.auth.success('Linked sign-in method', {
        'added': attempted.name,
        'uid': AppLog.redact(user.uid),
      });
    } on FirebaseAuthException catch (e) {
      // Already attached is a success for our purposes.
      if (e.code != 'provider-already-linked' &&
          e.code != 'credential-already-in-use') {
        rethrow;
      }
      AppLog.auth.debug('Provider already linked', {'code': e.code});
    }

    if ((user.displayName?.trim().isEmpty ?? true) &&
        fallbackName != null &&
        fallbackName.isNotEmpty) {
      try {
        await user.updateDisplayName(fallbackName);
        await user.reload();
      } catch (e) {
        AppLog.auth.warn('Display name not saved', {'error': e});
      }
    }

    startTokenAutoRefresh();
    await _persistToken(_auth.currentUser ?? user, forceRefresh: true);

    return AuthSignInResult(
      credential: result,
      isNewUser: false,
      provider: attempted,
    );
  }

  /// Signs out only when the user asks for it.
  Future<void> signOut() async {
    try {
      if (_googleReady) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      AppLog.auth.warn('Google sign-out error', {'error': e});
    }
    await _auth.signOut();
    await _sessionStore?.clear();
  }

  Future<void> _persistToken(User user, {required bool forceRefresh}) async {
    try {
      final token = await user.getIdToken(forceRefresh);
      await _sessionStore?.saveFromUser(user, idToken: token);
    } catch (e) {
      // Keep the stored session; the SDK retries refreshing on its own.
      await _sessionStore?.saveFromUser(user);
      AppLog.auth.warn('Refresh failed, session kept', {'error': e});
    }
  }

  Future<void> _notifyTelegramNewSignup(
    User user, {
    String? fallbackDisplayName,
    required AuthProviderKind provider,
  }) async {
    final source = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName
        : fallbackDisplayName;
    final names = TelegramNotifyService.splitDisplayName(source);
    final device = await DeviceContext.collect();

    await _telegram.notifyNewSignup(
      SignupReport(
        uid: user.uid,
        provider: provider.name,
        firstName: names.$1,
        surname: names.$2,
        email: user.email,
        emailVerified: user.emailVerified,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime,
        platform: device.platform,
        osVersion: device.osVersion,
        deviceModel: device.deviceModel,
        appVersion: device.appVersion,
        locale: device.locale,
        timeZone: device.timeZone,
      ),
    );
  }

  static String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
