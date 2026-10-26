import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../models/medical_report.dart';
import '../models/user_profile.dart';
import '../services/health_snapshot.dart';
import '../theme/app_theme.dart';

/// Compact "where you stand" bar for the top of the Analyze tab, combining
/// the body details the user entered with their latest report.
class HealthStatusStrip extends StatelessWidget {
  const HealthStatusStrip({
    super.key,
    required this.profile,
    required this.reports,
    this.onTap,
  });

  final UserProfile profile;
  final List<MedicalReport> reports;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final snapshot = HealthSnapshot.of(profile: profile, reports: reports);
    final tone = _toneColor(snapshot.tone);

    return Material(
      color: tone.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tone.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              _Indicator(snapshot: snapshot, tone: tone),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _headline(l10n, snapshot.tone),
                      style: theme.textTheme.titleMedium?.copyWith(color: tone),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _detail(l10n, snapshot),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, size: 20, color: tone),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 380.ms).slideY(begin: 0.05, end: 0);
  }

  static String _headline(AppL10n l10n, HealthTone tone) => switch (tone) {
        HealthTone.good => l10n.statusGood,
        HealthTone.watch => l10n.statusWatch,
        HealthTone.attention => l10n.statusAttention,
        HealthTone.unknown => l10n.statusUnknown,
      };

  /// Builds the supporting line from whatever the app actually knows, rather
  /// than printing placeholders for the parts it does not.
  static String _detail(AppL10n l10n, HealthSnapshot snapshot) {
    if (snapshot.isEmpty) return l10n.statusUnknownBody;

    final parts = <String>[];

    if (snapshot.bmi != null) {
      parts.add(l10n.statusBmi(snapshot.bmi!.toStringAsFixed(1)));
    } else if (snapshot.missingProfileFields.isNotEmpty) {
      parts.add(l10n.statusAddDetails(_fields(l10n, snapshot)));
    }

    if (snapshot.hasReport) {
      parts.add(
        snapshot.flagged > 0
            ? l10n.statusFlagged(snapshot.flagged)
            : l10n.statusAllClear(snapshot.tracked),
      );
    } else {
      parts.add(l10n.statusNoReport);
    }

    return parts.join(' · ');
  }

  static String _fields(AppL10n l10n, HealthSnapshot snapshot) {
    return snapshot.missingProfileFields
        .map(
          (f) => switch (f) {
            'weight' => l10n.fieldWeightLower,
            'height' => l10n.fieldHeightLower,
            _ => l10n.fieldAgeLower,
          },
        )
        .join(', ');
  }

  static Color _toneColor(HealthTone tone) => switch (tone) {
        HealthTone.good => AppColors.sage,
        HealthTone.watch => AppColors.amber,
        HealthTone.attention => AppColors.coral,
        HealthTone.unknown => AppColors.teal,
      };
}

/// BMI inside a ring when known, a plain icon when not.
class _Indicator extends StatelessWidget {
  const _Indicator({required this.snapshot, required this.tone});

  final HealthSnapshot snapshot;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bmi = snapshot.bmi;

    if (bmi == null) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.favorite_rounded, size: 19, color: tone),
      );
    }

    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (bmi / 40).clamp(0.0, 1.0)),
            duration: 800.ms,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 3.5,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation(tone),
              ),
            ),
          ),
          Text(
            bmi.toStringAsFixed(0),
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
