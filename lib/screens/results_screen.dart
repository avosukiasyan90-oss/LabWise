import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/medical_report.dart';
import '../models/report_comparison.dart';
import '../services/report_comparator.dart';
import '../theme/app_theme.dart';
import '../widgets/attached_file_card.dart';
import '../widgets/comparison_card.dart';
import '../widgets/marker_tile.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.report});

  final MedicalReport report;

  @override
  Widget build(BuildContext context) {
    final comparison = const ReportComparator().compare(report);
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat('EEEE, MMM d · HH:mm', locale)
        .format(report.uploadedAt);
    final abnormal = report.markers.where((m) => m.isAbnormal).toList();
    final others = report.markers.where((m) => !m.isAbnormal).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F4F0), AppColors.mist, AppColors.mist],
            stops: [0, 0.28, 1],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFFE8F4F0).withValues(alpha: 0.92),
                title: Text(l10n.yourResults),
                actions: [
                  IconButton(
                    tooltip: l10n.done,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      report.fileName,
                      style: theme.textTheme.headlineMedium,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
                    const SizedBox(height: 6),
                    Text(date, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 18),
                    _HeroSummary(report: report)
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 450.ms)
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1, 1),
                        ),
                    if (comparison != null) ...[
                      const SizedBox(height: 16),
                      ComparisonCard(comparison: comparison)
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 450.ms)
                          .slideY(begin: 0.05, end: 0),
                    ],
                    const SizedBox(height: 16),
                    AttachedFileCard(report: report),
                    const SizedBox(height: 16),
                    _DocumentDetails(report: report),
                    if (comparison != null) ...[
                      const SizedBox(height: 22),
                      _ChangesSection(comparison: comparison),
                    ],
                    if (report.whatToDo.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Text(l10n.suggestions, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 10),
                      ...report.whatToDo.asMap().entries.map(
                            (entry) => _SuggestionRow(
                              index: entry.key + 1,
                              text: entry.value,
                            ),
                          ),
                    ],
                    const SizedBox(height: 22),
                    if (abnormal.isNotEmpty) ...[
                      Text(l10n.needsAttention, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        l10n.needsAttentionSubtitle,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      ...abnormal.asMap().entries.map(
                            (e) => MarkerTile(marker: e.value, index: e.key),
                          ),
                    ],
                    if (others.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        abnormal.isEmpty ? l10n.allFindings : l10n.otherFindings,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.everyPointRead,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      ...others.asMap().entries.map(
                            (e) => MarkerTile(
                              marker: e.value,
                              index: e.key + abnormal.length,
                            ),
                          ),
                    ],
                    if (report.markers.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Text(
                          l10n.noStructuredPoints,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.resultsDisclaimer,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.ink),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({required this.report});

  final MedicalReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final tone = report.abnormalCount == 0
        ? AppColors.sage
        : report.abnormalCount <= 2
            ? AppColors.amber
            : AppColors.coral;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              report.healthLabel(AppL10n.of(context)),
              style: theme.textTheme.labelLarge?.copyWith(color: tone),
            ),
          ),
          const SizedBox(height: 14),
          Text(report.summary, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(
                value: '${report.markers.length}',
                label: l10n.pointsRead,
              ),
              const SizedBox(width: 12),
              _Stat(
                value: '${report.abnormalCount}',
                label: l10n.needAttentionLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocumentDetails extends StatelessWidget {
  const _DocumentDetails({required this.report});

  final MedicalReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final rows = <(String, String)>[
      if (report.clinicName != null) (l10n.fieldClinic, report.clinicName!),
      if (report.examTitle != null) (l10n.fieldExam, report.examTitle!),
      if (report.patientName != null) (l10n.fieldPatient, report.patientName!),
      if (report.reportNumber != null)
        (l10n.fieldReportNumber, report.reportNumber!),
      if (report.sampleDate != null)
        (l10n.fieldSampleDate, report.sampleDate!),
      if (report.doctorName != null) (l10n.fieldDoctor, report.doctorName!),
      if (report.method != null) (l10n.fieldMethod, report.method!),
      if (report.patientAddress != null)
        (l10n.fieldAddress, report.patientAddress!),
      if (report.patientPhone != null) (l10n.fieldPhone, report.patientPhone!),
      if (report.patientEmail != null) (l10n.fieldEmail, report.patientEmail!),
      if (report.licenseNumber != null)
        (l10n.fieldLabLicence, report.licenseNumber!),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

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
          Text(l10n.documentDetails, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(row.$1, style: theme.textTheme.bodyMedium),
                  ),
                  Expanded(
                    child: Text(
                      row.$2,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '$index',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.tealDark,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Per-marker before/after list, collapsed to the values that actually moved
/// until the reader asks for the rest.
class _ChangesSection extends StatefulWidget {
  const _ChangesSection({required this.comparison});

  final ReportComparison comparison;

  @override
  State<_ChangesSection> createState() => _ChangesSectionState();
}

class _ChangesSectionState extends State<_ChangesSection> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final comparison = widget.comparison;
    final notable = comparison.notable;
    final shown = _showAll ? comparison.deltas : notable;
    final hasMore = comparison.deltas.length > notable.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.whatChanged, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(l10n.whatChangedSubtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 10),
        ...shown.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MarkerDeltaRow(delta: entry.value)
                    .animate()
                    .fadeIn(
                      delay: (40 * entry.key).ms,
                      duration: 300.ms,
                    )
                    .slideX(begin: 0.03, end: 0),
              ),
            ),
        if (hasMore)
          TextButton.icon(
            onPressed: () => setState(() => _showAll = !_showAll),
            icon: Icon(
              _showAll
                  ? Icons.unfold_less_rounded
                  : Icons.unfold_more_rounded,
              size: 18,
            ),
            label: Text(
              _showAll
                  ? l10n.showFewerChanges
                  : l10n.showAllChanges(comparison.deltas.length),
            ),
          ),
      ],
    );
  }
}
