import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../models/medical_report.dart';
import '../models/user_profile.dart';
import '../models/wellness_plan.dart';
import '../services/activity_controller.dart';
import '../services/wellness_planner.dart';
import '../widgets/activity_summary_card.dart';
import 'activity_screen.dart';
import 'targets_screen.dart';
import '../theme/app_theme.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({
    super.key,
    required this.profile,
    required this.reports,
    required this.activityController,
    this.onOpenProfile,
  });

  final UserProfile profile;
  final List<MedicalReport> reports;
  final ActivityController activityController;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final plan = const WellnessPlanner().build(
      l10n: l10n,
      profile: profile,
      reports: reports,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            l10n.planTitle,
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 36),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: 6),
          Text(
            plan.headline,
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ).animate().fadeIn(delay: 60.ms, duration: 400.ms),
          const SizedBox(height: 20),
          if (!plan.isPersonalized)
            _SetupPrompt(plan: plan, onOpenProfile: onOpenProfile)
          else ...[
            _MetricsCard(
                  plan: plan,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TargetsScreen(plan: plan, profile: profile),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 100.ms, duration: 450.ms)
                .slideY(begin: 0.05, end: 0),
            if (plan.missingFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MissingHint(
                missing: plan.missingFields,
                onOpenProfile: onOpenProfile,
              ),
            ],
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.calendar_month_rounded,
              title: l10n.activityTitle,
              subtitle: l10n.activitySubtitle,
            ),
            const SizedBox(height: 12),
            ActivitySummaryCard(
                  controller: activityController,
                  stepGoal: plan.stepGoal,
                  onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ActivityScreen(
                        controller: activityController,
                        stepGoal: plan.stepGoal,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 120.ms, duration: 450.ms)
                .slideY(begin: 0.04, end: 0),
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.schedule_rounded,
              title: l10n.eatingWindow,
              subtitle: plan.eatingWindow == null
                  ? l10n.eatingWindowFallback
                  : l10n.eatingWindowSubtitle(plan.eatingWindow!),
            ),
            const SizedBox(height: 12),
            ...plan.mealWindows.asMap().entries.map(
              (entry) =>
                  _MealRow(
                        meal: entry.value,
                        isLast: entry.key == plan.mealWindows.length - 1,
                      )
                      .animate()
                      .fadeIn(
                        delay: (140 + 60 * entry.key).ms,
                        duration: 350.ms,
                      )
                      .slideX(begin: 0.04, end: 0),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              icon: Icons.directions_run_rounded,
              title: l10n.movement,
              subtitle: l10n.movementSubtitle,
            ),
            const SizedBox(height: 12),
            ...plan.activities.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ActivityCard(activity: entry.value)
                    .animate()
                    .fadeIn(delay: (180 + 70 * entry.key).ms, duration: 380.ms)
                    .slideY(begin: 0.05, end: 0),
              ),
            ),
            if (plan.habits.isNotEmpty) ...[
              const SizedBox(height: 14),
              _SectionHeader(
                icon: Icons.check_circle_outline_rounded,
                title: l10n.dailyHabits,
                subtitle: l10n.dailyHabitsSubtitle,
              ),
              const SizedBox(height: 12),
              _HabitsCard(
                habits: plan.habits,
              ).animate().fadeIn(delay: 220.ms, duration: 400.ms),
            ],
            if (plan.reportNotes.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(
                icon: Icons.insights_rounded,
                title: l10n.fromYourReports,
                subtitle: l10n.fromYourReportsSubtitle,
              ),
              const SizedBox(height: 12),
              ...plan.reportNotes.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NoteCard(
                    text: note,
                  ).animate().fadeIn(delay: 260.ms, duration: 400.ms),
                ),
              ),
            ],
          ],
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.sand,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l10n.planDisclaimer,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupPrompt extends StatelessWidget {
  const _SetupPrompt({required this.plan, this.onOpenProfile});

  final WellnessPlan plan;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 34,
                  color: AppColors.tealDark,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 1600.ms,
              ),
          const SizedBox(height: 18),
          Text(l10n.planSetupTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l10n.planSetupBody(plan.missingFields.join(', ')),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenProfile,
              icon: const Icon(Icons.person_outline_rounded),
              label: Text(l10n.openProfile),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 450.ms);
  }
}

class _MissingHint extends StatelessWidget {
  const _MissingHint({required this.missing, this.onOpenProfile});

  final List<String> missing;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    return Material(
      color: AppColors.mint.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpenProfile,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(
                Icons.tips_and_updates_outlined,
                color: AppColors.tealDark,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.planMissingHint(missing.join(', ')),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.tealDark,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.tealDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.plan, this.onTap});

  final WellnessPlan plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final bmi = plan.bmi;
    final tone = switch (bmi) {
      null => AppColors.teal,
      < 18.5 => AppColors.amber,
      < 25 => AppColors.sage,
      < 30 => AppColors.amber,
      _ => AppColors.coral,
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: ((bmi ?? 0) / 40).clamp(0.0, 1.0),
                          ),
                          duration: 900.ms,
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => SizedBox(
                            width: 76,
                            height: 76,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 7,
                              backgroundColor: AppColors.mist,
                              valueColor: AlwaysStoppedAnimation(tone),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bmi == null ? '—' : bmi.toStringAsFixed(1),
                              style: theme.textTheme.titleLarge,
                            ),
                            Text('BMI', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: tone.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            plan.bmiLabel ?? l10n.bmiProfileNeeded,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: tone,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.targetsTuned,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _Metric(
                    icon: Icons.local_fire_department_outlined,
                    value: plan.dailyCalories == null
                        ? '—'
                        : '${plan.dailyCalories}',
                    label: l10n.metricKcal,
                  ),
                  const SizedBox(width: 10),
                  _Metric(
                    icon: Icons.water_drop_outlined,
                    value: plan.waterLitres == null
                        ? '—'
                        : '${plan.waterLitres} L',
                    label: l10n.metricWater,
                  ),
                  const SizedBox(width: 10),
                  _Metric(
                    icon: Icons.directions_walk_rounded,
                    value: plan.stepGoal == null ? '—' : '${plan.stepGoal}',
                    label: l10n.metricSteps,
                  ),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.help_outline_rounded,
                      size: 15,
                      color: AppColors.tealDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.targetsTapHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.tealDark,
                        fontSize: 13,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 17,
                      color: AppColors.tealDark,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.tealDark, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.tealDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              Text(subtitle, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal, required this.isLast});

  final MealWindow meal;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: Icon(meal.icon, size: 18, color: AppColors.tealDark),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.line)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(meal.time, style: theme.textTheme.titleMedium),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          meal.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(meal.idea, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final ActivityIdea activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(activity.icon, color: AppColors.tealDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  activity.schedule,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(activity.why, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsCard extends StatelessWidget {
  const _HabitsCard({required this.habits});

  final List<String> habits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final habit in habits)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.sage,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(habit, style: theme.textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.priority_high_rounded,
            size: 20,
            color: AppColors.amber,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
