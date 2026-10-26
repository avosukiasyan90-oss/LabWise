import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/daily_activity.dart';
import '../services/activity_controller.dart';
import '../services/health_service.dart';
import '../theme/app_theme.dart';

/// Glanceable activity strip for the Plan tab. Tapping it opens the full
/// calendar rather than filling the tab with a month grid.
class ActivitySummaryCard extends StatefulWidget {
  const ActivitySummaryCard({
    super.key,
    required this.controller,
    required this.onOpen,
    this.stepGoal,
  });

  final ActivityController controller;
  final VoidCallback onOpen;
  final int? stepGoal;

  @override
  State<ActivitySummaryCard> createState() => _ActivitySummaryCardState();
}

class _ActivitySummaryCardState extends State<ActivitySummaryCard> {
  @override
  void initState() {
    super.initState();
    widget.controller.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;

        if (controller.availability == HealthAvailability.unsupported &&
            !controller.loading) {
          return const SizedBox.shrink();
        }

        if (controller.availability == HealthAvailability.pluginMissing) {
          return _Notice(message: AppL10n.of(context).activityRestartNeeded);
        }

        if (!controller.isReady) {
          return _CompactConnect(
            busy: controller.connecting,
            needsInstall:
                controller.availability == HealthAvailability.needsHealthConnect,
            onConnect: controller.connect,
          );
        }

        return _Summary(
          controller: controller,
          stepGoal: widget.stepGoal,
          onOpen: widget.onOpen,
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.controller,
    required this.stepGoal,
    required this.onOpen,
  });

  final ActivityController controller;
  final int? stepGoal;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final today = controller.today;
    final week = controller.recentDays(7);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(l10n.activityToday, style: theme.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    l10n.activityOpenCalendar,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.tealDark, fontSize: 12),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.tealDark),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${today?.steps ?? 0}',
                    style: theme.textTheme.displayMedium?.copyWith(fontSize: 30),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      l10n.metricSteps,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const Spacer(),
                  if (today != null && today.totalKm > 0)
                    _Chip(
                      icon: Icons.straighten_rounded,
                      label: '${today.totalKm.toStringAsFixed(1)} km',
                    ),
                  if (today != null && today.activeMinutes > 0) ...[
                    const SizedBox(width: 6),
                    _Chip(
                      icon: Icons.timer_outlined,
                      label: l10n.activityDurationMinutes(today.activeMinutes),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              _WeekStrip(week: week, stepGoal: stepGoal),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seven small bars, one per day, filled by the share of the step goal met.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.week, required this.stepGoal});

  final List<MapEntry<DateTime, DailyActivity?>> week;
  final int? stepGoal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final goal = (stepGoal ?? 8000).clamp(1000, 30000);
    final initials = DateFormat.E(locale);

    return Row(
      children: [
        for (final entry in week) ...[
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 34,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: ((entry.value?.steps ?? 0) / goal)
                            .clamp(0.06, 1.0)
                            .toDouble(),
                      ),
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => FractionallySizedBox(
                        heightFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: entry.value == null
                                ? AppColors.mist
                                : _tone(entry.value!),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  initials.format(entry.key).substring(0, 1).toUpperCase(),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (entry != week.last) const SizedBox(width: 6),
        ],
      ],
    );
  }

  static Color _tone(DailyActivity day) {
    if (day.cycleKm > day.walkRunKm) return AppColors.amber;
    if (day.sessions.any((s) => s.kind == ActivityKind.running)) {
      return AppColors.coral;
    }
    return AppColors.sage;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.tealDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// One-line version of the connect prompt, sized for the Plan tab.
class _CompactConnect extends StatelessWidget {
  const _CompactConnect({
    required this.busy,
    required this.needsInstall,
    required this.onConnect,
  });

  final bool busy;
  final bool needsInstall;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.favorite_rounded,
                size: 20, color: AppColors.tealDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.activityConnectTitle,
                    style: theme.textTheme.titleMedium),
                Text(
                  l10n.activityConnectShort,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: busy ? null : onConnect,
            child: busy
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    needsInstall
                        ? l10n.activityInstallHealthConnect
                        : l10n.activityConnectButton,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.restart_alt_rounded, size: 20, color: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
