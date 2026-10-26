import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/medical_report.dart';
import '../services/report_comparator.dart';
import '../theme/app_theme.dart';
import 'comparison_card.dart';

class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({
    super.key,
    required this.report,
    this.onTap,
    this.onDelete,
  });

  final MedicalReport report;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date =
        DateFormat('MMM d, yyyy · HH:mm', locale).format(report.uploadedAt);
    final comparison = const ReportComparator().compare(report);
    final tone = report.abnormalCount == 0
        ? AppColors.sage
        : report.abnormalCount <= 2
            ? AppColors.amber
            : AppColors.coral;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      report.fileName.toLowerCase().endsWith('.pdf')
                          ? Icons.picture_as_pdf_rounded
                          : Icons.description_outlined,
                      color: AppColors.tealDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(date, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: AppColors.muted,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      report.healthLabel(l10n),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: tone,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (comparison != null) TrendChip(comparison: comparison),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                report.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.science_outlined,
                    label: l10n.markersCount(report.markers.length),
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.priority_high_rounded,
                    label: l10n.toReviewCount(report.abnormalCount),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ],
              ),
              if (report.previous != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.sync_alt_rounded,
                      size: 13,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        l10n.replacedEarlierVersion(
                          DateFormat.yMMMd(locale)
                              .format(report.previous!.uploadedAt),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
