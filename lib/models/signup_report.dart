/// Everything known about a new signup at the moment it happens.
///
/// Gathered once and passed as a value so the Telegram service stays a pure
/// formatter and can be tested without plugins or a network.
class SignupReport {
  const SignupReport({
    required this.uid,
    required this.provider,
    this.firstName = '',
    this.surname = '',
    this.email,
    this.emailVerified = false,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
    this.platform,
    this.osVersion,
    this.deviceModel,
    this.appVersion,
    this.locale,
    this.timeZone,
  });

  // Identity, as the provider reported it.
  final String uid;
  final String provider;
  final String firstName;
  final String surname;
  final String? email;
  final bool emailVerified;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;

  // Where they signed up from.
  final String? platform;
  final String? osVersion;
  final String? deviceModel;
  final String? appVersion;
  final String? locale;
  final String? timeZone;

  String get fullName => [
        if (firstName.trim().isNotEmpty) firstName.trim(),
        if (surname.trim().isNotEmpty) surname.trim(),
      ].join(' ');
}
