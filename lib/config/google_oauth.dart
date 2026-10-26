/// Google OAuth client IDs for LabWise (from Firebase / Google Cloud).
class GoogleOAuthConfig {
  /// iOS OAuth client ID (GoogleService-Info.plist CLIENT_ID).
  static const String iosClientId = '414398000383-38tmu94r0di7rang5j2mce0pil61bnq1.apps.googleusercontent.com';

  /// Web client ID — required so Google Sign-In returns an ID token
  /// that Firebase Auth can accept.
  static const String serverClientId = '414398000383-h04l2r7pmd7ng2r5bobjmfn08qahrdno.apps.googleusercontent.com';
}
