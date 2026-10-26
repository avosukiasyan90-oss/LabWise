import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../models/wellness_plan.dart';
import '../theme/app_theme.dart';

/// Explains every number on the Plan tab's targets card: what it is, why it
/// is worth tracking, and exactly how it was derived from the profile.
///
/// The engine is deterministic, so the arithmetic can be shown honestly
/// rather than presented as a recommendation from nowhere.
class TargetsScreen extends StatelessWidget {
  const TargetsScreen({
    super.key,
    required this.plan,
    required this.profile,
  });

  final WellnessPlan plan;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        title: Text(l10n.targetsTitle),
        backgroundColor: AppColors.mist,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(l10n.targetsSubtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 18),
            _InputsCard(profile: profile, l10n: l10n),
            const SizedBox(height: 18),
            _TargetSection(
              icon: Icons.monitor_weight_outlined,
              title: l10n.targetBmiTitle,
              value: plan.bmi?.toStringAsFixed(1) ?? '—',
              caption: plan.bmiLabel,
              what: l10n.targetBmiWhat,
              why: l10n.targetBmiWhy,
              how: l10n.targetBmiBands,
              caveat: l10n.targetBmiCaveat,
              index: 0,
            ),
            _TargetSection(
              icon: Icons.local_fire_department_outlined,
              title: l10n.targetCaloriesTitle,
              value: plan.dailyCalories == null
                  ? '—'
                  : '${plan.dailyCalories}',
              caption: l10n.metricKcal,
              what: l10n.targetCaloriesWhat,
              why: l10n.targetCaloriesWhy,
              how: l10n.targetCaloriesHow,
              extra: _calorieAdjustment(l10n, plan.bmi),
              index: 1,
            ),
            _TargetSection(
              icon: Icons.water_drop_outlined,
              title: l10n.targetWaterTitle,
              value: plan.waterLitres == null ? '—' : '${plan.waterLitres} L',
              caption: l10n.metricWater,
              what: l10n.targetWaterWhat,
              why: l10n.targetWaterWhy,
              caveat: l10n.targetWaterCaveat,
              index: 2,
            ),
            _TargetSection(
              icon: Icons.directions_walk_rounded,
              title: l10n.targetStepsTitle,
              value: plan.stepGoal == null ? '—' : '${plan.stepGoal}',
              caption: l10n.metricSteps,
              what: l10n.targetStepsWhat,
              why: l10n.targetStepsWhy,
              how: l10n.targetStepsHow,
              index: 3,
            ),
            const SizedBox(height: 6),
            _ClinicianNote(l10n: l10n),
          ],
        ),
      ),
    );
  }

  static String? _calorieAdjustment(AppL10n l10n, double? bmi) {
    if (bmi == null) return null;
    if (bmi < 18.5) return l10n.targetCaloriesAdjustUnder;
    if (bmi < 25) return l10n.targetCaloriesAdjustHealthy;
    if (bmi < 30) return l10n.targetCaloriesAdjustAbove;
    return l10n.targetCaloriesAdjustWellAbove;
  }
}

class _InputsCard extends StatelessWidget {
  const _InputsCard({required this.profile, required this.l10n});

  final UserProfile profile;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String show(num? value) => value == null ? '—' : '$value';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 18, color: AppColors.tealDark),
              const SizedBox(width: 8),
              Text(
                l10n.targetsInputsTitle,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: AppColors.tealDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.targetsInputsBody(
              show(profile.weightKg),
              show(profile.heightCm),
              show(profile.age),
            ),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(l10n.targetsInputsNote, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TargetSection extends StatelessWidget {
  const _TargetSection({
    required this.icon,
    required this.title,
    required this.value,
    required this.what,
    required this.why,
    required this.index,
    this.caption,
    this.how,
    this.caveat,
    this.extra,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? caption;
  final String what;
  final String why;
  final String? how;
  final String? caveat;
  final String? extra;

  /// Position in the list, used only to stagger the entry animation.
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.tealDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleLarge),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: theme.textTheme.headlineSmall),
                    if (caption != null)
                      Text(caption!, style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(what, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 10),
            _Labelled(icon: Icons.flag_outlined, text: why),
            if (extra != null) ...[
              const SizedBox(height: 8),
              _Labelled(icon: Icons.tune_rounded, text: extra!),
            ],
            if (how != null) ...[
              const SizedBox(height: 8),
              _Labelled(icon: Icons.calculate_outlined, text: how!),
            ],
            if (caveat != null) ...[
              const SizedBox(height: 8),
              _Labelled(
                icon: Icons.info_outline_rounded,
                text: caveat!,
                tone: AppColors.amber,
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (80 * index).ms, duration: 380.ms)
        .slideY(begin: 0.04, end: 0);
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.icon, required this.text, this.tone});

  final IconData icon;
  final String text;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tone ?? AppColors.muted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tone == null ? null : AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _ClinicianNote extends StatelessWidget {
  const _ClinicianNote({required this.l10n});

  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information_outlined,
                  size: 18, color: AppColors.ink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.targetsClinicianTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.targetsClinicianBody,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
