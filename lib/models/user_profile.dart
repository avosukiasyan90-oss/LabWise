/// Account profile for LabWise.
///
/// Identity fields ([email], [displayName], [photoUrl]) come from the Google
/// account and are never editable in the app. The health fields are optional
/// and user-provided.
class UserProfile {
  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.weightKg,
    this.heightCm,
    this.age,
    this.country,
    this.onboardedAt,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  final double? weightKg;
  final double? heightCm;
  final int? age;
  final String? country;

  /// Set once the user either saved or skipped the setup step.
  final DateTime? onboardedAt;

  bool get hasOnboarded => onboardedAt != null;

  bool get hasHealthDetails =>
      weightKg != null || heightCm != null || age != null || country != null;

  String get firstName {
    final parts = (displayName ?? '').trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    return parts.isEmpty ? '' : parts.first;
  }

  String get surname {
    final parts = (displayName ?? '').trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    if (parts.length < 2) return '';
    return parts.sublist(1).join(' ');
  }

  /// Body mass index, when both weight and height are known.
  double? get bmi {
    final w = weightKg;
    final h = heightCm;
    if (w == null || h == null || h <= 0) return null;
    final meters = h / 100;
    return w / (meters * meters);
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    double? weightKg,
    double? heightCm,
    int? age,
    String? country,
    DateTime? onboardedAt,
    bool clearWeight = false,
    bool clearHeight = false,
    bool clearAge = false,
    bool clearCountry = false,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      weightKg: clearWeight ? null : (weightKg ?? this.weightKg),
      heightCm: clearHeight ? null : (heightCm ?? this.heightCm),
      age: clearAge ? null : (age ?? this.age),
      country: clearCountry ? null : (country ?? this.country),
      onboardedAt: onboardedAt ?? this.onboardedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          other.uid == uid &&
          other.email == email &&
          other.displayName == displayName &&
          other.photoUrl == photoUrl &&
          other.weightKg == weightKg &&
          other.heightCm == heightCm &&
          other.age == age &&
          other.country == country &&
          other.onboardedAt == onboardedAt;

  @override
  int get hashCode => Object.hash(
        uid,
        email,
        displayName,
        photoUrl,
        weightKg,
        heightCm,
        age,
        country,
        onboardedAt,
      );

  Map<String, dynamic> toHealthJson() => {
        'weightKg': weightKg,
        'heightCm': heightCm,
        'age': age,
        'country': country,
        'onboardedAt': onboardedAt?.toIso8601String(),
      };

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        ...toHealthJson(),
      };

  factory UserProfile.fromJson(String uid, Map<String, dynamic> json) {
    double? toDouble(Object? v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(',', '.'));
    }

    int? toInt(Object? v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    DateTime? toDate(Object? v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return UserProfile(
      uid: uid,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      weightKg: toDouble(json['weightKg']),
      heightCm: toDouble(json['heightCm']),
      age: toInt(json['age']),
      country: json['country'] as String?,
      onboardedAt: toDate(json['onboardedAt']),
    );
  }
}
