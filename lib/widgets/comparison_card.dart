import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/report_comparison.dart';
import '../theme/app_theme.dart';

Color trendColor(TrendDirection direction) => switch (direction) {
      TrendDirection.improved => AppColors.sage,
      TrendDirection.worsened => AppColors.coral,
      TrendDirection.steady => AppColors.teal,
    };

IconData trendIcon(TrendDirection direction) => switch (direction) {
      TrendDirection.improved => Icons.trending_up_rounded,
      TrendDirection.worsened => Icons.trending_down_rounded,
      TrendDirection.steady => Icons.trending_flat_rounded,
    };

/// Headline card that answers "is this better than last time, and by how
/// much?" at a glance.
class ComparisonCard extends StatelessWidget {
  const ComparisonCard({super.key, required this.comparison});

  final ReportComparison comparison;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final direction = comparison.overall;
    final tone = trendColor(direction);
    final shift = comparison.scoreChange ?? 0;

    final headline = switch (direction) {
      TrendDirection.improved => l10n.trendBetter,
      TrendDirection.worsened => l10n.trendWorse,
      TrendDirection.steady => l10n.trendSteady,
    };
    final body = switch (direction) {
      TrendDirection.improved => l10n.trendBetterBody,
      TrendDirection.worsened => l10n.trendWorseBody,
      TrendDirection.steady => l10n.trendSteadyBody,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tone.withValues(alpha: 0.14), tone.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(trendIcon(direction), color: tone),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.comparisonTitle, style: theme.textTheme.bodyMedium),
                    Text(
                      headline,
                      style: theme.textTheme.titleLarge?.copyWith(color: tone),
                    ),
                  ],
                ),
              ),
              _ScoreShift(shift: shift, tone: tone),
            ],
          ),
          const SizedBox(height: 14),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _RangeBar(comparison: comparison, tone: tone),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (comparison.improved.isNotEmpty)
                _CountChip(
                  icon: Icons.arrow_upward_rounded,
                  label: l10n.countImproved(comparison.improved.length),
                  tone: AppColors.sage,
                ),
              if (comparison.worsened.isNotEmpty)
                _CountChip(
                  icon: Icons.arrow_downward_rounded,
                  label: l10n.countWorsened(comparison.worsened.length),
                  tone: AppColors.coral,
                ),
              if (comparison.steady.isNotEmpty)
                _CountChip(
                  icon: Icons.remove_rounded,
                  label: l10n.countSteady(comparison.steady.length),
                  tone: AppColors.muted,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 15, color: AppColors.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.previousTestOn(
                    DateFormat.yMMMd(locale).format(comparison.previous.uploadedAt),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated count of how many percentage points the in-range share moved.
class _ScoreShift extends StatelessWidget {
  const _ScoreShift({required this.shift, required this.tone});

  final double shift;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final rounded = shift.round();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: shift),
      duration: 900.ms,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final shown = value.round();
        final label = rounded == 0
            ? l10n.scoreNoChange
            : shown > 0
                ? l10n.scoreBetterBy('$shown')
                : l10n.scoreWorseBy('$shown');
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: tone),
          ),
        );
      },
    );
  }
}

/// Twin bars showing the share of values in range before and after.
class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.comparison, required this.tone});

  final ReportComparison comparison;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final total = comparison.comparedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.inRangeNow(comparison.currentInRange, total),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.wasInRange(comparison.previousInRange, total),
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 10, color: Colors.white.withValues(alpha: 0.7)),
              FractionallySizedBox(
                widthFactor: total == 0 ? 0 : comparison.previousInRange / total,
                child: Container(
                  height: 10,
                  color: AppColors.muted.withValues(alpha: 0.35),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0,
                  end: total == 0 ? 0 : comparison.currentInRange / total,
                ),
                duration: 900.ms,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  widthFactor: value,
                  child: Container(height: 10, color: tone),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tone),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: tone, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// One marker's before/after values with the size of the move.
class MarkerDeltaRow extends StatelessWidget {
  const MarkerDeltaRow({super.key, required this.delta});

  final MarkerDelta delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final tone = trendColor(delta.direction);
    final percent = delta.percentChange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(trendIcon(delta.direction), size: 17, color: tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delta.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      delta.previous.display,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_right_alt_rounded,
                        size: 16,
                        color: AppColors.muted,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${delta.current.displayResult}'
                        '${delta.unit.isEmpty ? '' : ' ${delta.unit}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (percent != null)
                Text(
                  '${percent > 0 ? '+' : ''}${percent.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: tone, fontSize: 14),
                ),
              if (delta.enteredRange)
                Text(
                  l10n.backInRange,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.sage, fontSize: 11),
                )
              else if (delta.leftRange)
                Text(
                  l10n.leftRange,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.coral, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact badge for History cards.
class TrendChip extends StatelessWidget {
  const TrendChip({super.key, required this.comparison});

  final ReportComparison comparison;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final direction = comparison.overall;
    final tone = trendColor(direction);
    final label = switch (direction) {
      TrendDirection.improved => l10n.countImproved(comparison.improved.length),
      TrendDirection.worsened => l10n.countWorsened(comparison.worsened.length),
      TrendDirection.steady => l10n.trendSteady,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon(direction), size: 13, color: tone),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: tone, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
