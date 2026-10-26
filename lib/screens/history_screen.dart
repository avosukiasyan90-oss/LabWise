import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../models/medical_report.dart';
import '../models/report_category.dart';
import '../models/report_comparison.dart';
import '../services/report_comparator.dart';
import '../theme/app_theme.dart';
import '../widgets/report_summary_card.dart';
import 'results_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.reports,
    required this.onDelete,
  });

  final List<MedicalReport> reports;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final folders = groupByCategory(reports);

    return SafeArea(
      child: reports.isEmpty
          ? const _EmptyHistory()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                Text(
                  l10n.historyTitle,
                  style: theme.textTheme.displayMedium?.copyWith(fontSize: 36),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.06, end: 0),
                const SizedBox(height: 6),
                Text(
                  l10n.historySummary(reports.length, folders.length),
                  style:
                      theme.textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                ...folders.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CategoryFolder(
                          category: entry.value.key,
                          reports: entry.value.value,
                          initiallyExpanded: entry.key == 0,
                          onDelete: onDelete,
                        )
                            .animate()
                            .fadeIn(
                              delay: (60 * entry.key).ms,
                              duration: 350.ms,
                            )
                            .slideY(begin: 0.05, end: 0),
                      ),
                    ),
              ],
            ),
    );
  }
}

class _CategoryFolder extends StatelessWidget {
  const _CategoryFolder({
    required this.category,
    required this.reports,
    required this.initiallyExpanded,
    required this.onDelete,
  });

  final ReportCategory category;
  final List<MedicalReport> reports;
  final bool initiallyExpanded;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final needsAttention =
        reports.fold<int>(0, (sum, r) => sum + r.abnormalCount);
    const comparator = ReportComparator();
    final improving = reports
        .map(comparator.compare)
        .whereType<ReportComparison>()
        .where((c) => c.overall == TrendDirection.improved)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Removes the default divider lines so the folder reads as one card.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          shape: const Border(),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(category.icon, color: AppColors.tealDark),
          ),
          title: Text(category.label(l10n), style: theme.textTheme.titleLarge),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    needsAttention > 0
                        ? '${l10n.reportCount(reports.length)} · '
                            '${l10n.needAttentionSuffix(needsAttention)}'
                        : l10n.reportCount(reports.length),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (improving > 0) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.trending_up_rounded,
                    size: 14,
                    color: AppColors.sage,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    l10n.folderTrendImproved(improving),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.sage,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
              child: Text(
                category.description(l10n),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.muted),
              ),
            ),
            ...reports.map(
              (report) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ReportSummaryCard(
                  report: report,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResultsScreen(report: report),
                    ),
                  ),
                  onDelete: () => _confirmDelete(context, report),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MedicalReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppL10n.of(ctx);
        return AlertDialog(
          title: Text(l10n.deleteReportTitle),
          content: Text(l10n.deleteReportBody(report.fileName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await onDelete(report.id);
    }
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 40,
                color: AppColors.tealDark,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.04, 1.04),
                  duration: 1800.ms,
                ),
            const SizedBox(height: 22),
            Text(l10n.noReportsTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l10n.noReportsBody,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
