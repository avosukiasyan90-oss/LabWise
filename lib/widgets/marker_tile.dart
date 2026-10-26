import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/lab_marker.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class MarkerTile extends StatelessWidget {
  const MarkerTile({
    super.key,
    required this.marker,
    required this.index,
  });

  final LabMarker marker;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: marker.isAbnormal
              ? AppColors.amber.withValues(alpha: 0.35)
              : AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  marker.name,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              StatusBadge(status: marker.status),
            ],
          ),
          if (marker.assayCode != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.markerCode(marker.assayCode!),
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  marker.displayResult,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.tealDark,
                  ),
                ),
              ),
              if (marker.unit.isNotEmpty) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    marker.unit,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
              const Spacer(),
              if (marker.referenceRange != null)
                Flexible(
                  child: Text(
                    l10n.markerRef(marker.referenceRange!),
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ),
            ],
          ),
          if (marker.information != null) ...[
            const SizedBox(height: 14),
            _InsightBlock(
              label: l10n.markerInformation,
              icon: Icons.info_outline_rounded,
              color: AppColors.teal,
              text: marker.information!,
            ),
          ],
          if (marker.description != null) ...[
            const SizedBox(height: 8),
            _InsightBlock(
              label: l10n.markerDescription,
              icon: Icons.menu_book_outlined,
              color: AppColors.muted,
              text: marker.description!,
            ),
          ],
          if (marker.recommendation != null) ...[
            const SizedBox(height: 8),
            _InsightBlock(
              label: l10n.markerSuggestion,
              icon: Icons.tips_and_updates_outlined,
              color: marker.isAbnormal ? AppColors.amber : AppColors.sage,
              text: marker.recommendation!,
              emphasized: true,
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (60 * index).ms, duration: 350.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

class _InsightBlock extends StatelessWidget {
  const _InsightBlock({
    required this.label,
    required this.icon,
    required this.color,
    required this.text,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasized ? AppColors.sand : AppColors.mist,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
