import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../models/medical_report.dart';
import '../models/report_comparison.dart';
import '../models/user_profile.dart';
import '../services/file_extractor.dart';
import '../services/file_hash.dart';
import '../services/medical_analyzer.dart';
import '../services/report_comparator.dart';
import '../services/report_file_store.dart';
import '../theme/app_theme.dart';
import '../widgets/health_status_strip.dart';
import '../widgets/upload_zone.dart';
import 'results_screen.dart';
import '../services/app_log.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({
    super.key,
    required this.onReportSaved,
    required this.existingReports,
    required this.profile,
    this.onOpenHistory,
    this.onOpenPlan,
  });

  /// [replacing] is the id of the earlier run of the same test that this
  /// upload supersedes, when there is one.
  final Future<void> Function(MedicalReport report, {String? replacing})
      onReportSaved;
  final List<MedicalReport> existingReports;
  final UserProfile profile;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenPlan;

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final _extractor = FileExtractor();
  final _analyzer = MedicalAnalyzer();
  final _fileStore = ReportFileStore();
  final _comparator = const ReportComparator();
  bool _busy = false;

  Future<void> _pickAndAnalyze() async {
    final l10n = AppL10n.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    AppLog.parse.info('File picked', {'name': file.name, 'bytes': file.size});
    final bytes = file.bytes;
    if (bytes == null) {
      _showError(l10n.errorReadFile);
      return;
    }

    final contentHash = sha256Hex(bytes);
    final duplicate = await _findDuplicate(
      fileName: file.name,
      contentHash: contentHash,
      bytes: bytes,
    );
    if (duplicate != null) {
      AppLog.parse.warn('Duplicate upload blocked', {'file': file.name});
      await _showAlreadyUploadedDialog(duplicate);
      return;
    }

    setState(() => _busy = true);
    try {
      final text = await _extractor.extractText(
        fileName: file.name,
        bytes: bytes,
      );
      var report = _analyzer.analyze(fileName: file.name, text: text);
      AppLog.parse.success('Parsed report', {
        'chars': text.length,
        'markers': report.markers.length,
        'flagged': report.abnormalCount,
      });
      final storedPath = await _fileStore.save(
        reportId: report.id,
        fileName: file.name,
        bytes: bytes,
      );
      report = report.copyWith(
        storedFilePath: storedPath,
        fileContentHash: contentHash,
      );

      // A repeat of a test already in History replaces it, carrying the old
      // values forward so the results screen can show what changed.
      final superseded = _comparator.findPreviousInSeries(
        report,
        widget.existingReports,
      );
      if (superseded != null) {
        AppLog.history.info('Superseding earlier run of this test');
        report = report.copyWith(previous: ReportSnapshot.of(superseded));
      }

      await widget.onReportSaved(report, replacing: superseded?.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultsScreen(report: report)),
      );
    } catch (e) {
      _showError(_friendlyError(l10n, e));
      AppLog.parse.error('Analysis failed', error: e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<MedicalReport?> _findDuplicate({
    required String fileName,
    required String contentHash,
    required Uint8List bytes,
  }) async {
    for (final report in widget.existingReports) {
      final savedHash = report.fileContentHash;
      if (savedHash != null && savedHash == contentHash) {
        return report;
      }
    }

    // Older history entries may lack a hash — compare stored bytes when names match.
    for (final report in widget.existingReports) {
      if (report.fileName != fileName) continue;
      if (report.fileContentHash != null) continue;
      final stored = await _fileStore.readBytes(report.storedFilePath);
      if (stored == null || stored.isEmpty) continue;
      if (sha256Hex(stored) == contentHash) {
        return report;
      }
    }
    return null;
  }

  Future<void> _showAlreadyUploadedDialog(MedicalReport existing) async {
    if (!mounted) return;
    final goToHistory = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppL10n.of(ctx);
        return AlertDialog(
          title: Text(l10n.alreadyUploadedTitle),
          content: Text(l10n.alreadyUploadedBody(existing.fileName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.ok),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.viewHistory),
            ),
          ],
        );
      },
    );
    if (goToHistory == true) {
      widget.onOpenHistory?.call();
    }
  }

  String _friendlyError(AppL10n l10n, Object e) {
    final message = e.toString().replaceFirst('Exception: ', '');
    if (message.contains('UnsupportedError') || e is UnsupportedError) {
      return e is UnsupportedError
          ? e.message ?? l10n.errorUnsupportedType
          : message;
    }
    if (message.contains('scanned')) return l10n.errorScannedPdf;
    return l10n.errorGeneric;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            l10n.appTitle,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 40,
              color: AppColors.tealDark,
            ),
          )
              .animate()
              .fadeIn(duration: 450.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 8),
          Text(
            l10n.analyzeIntro,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.muted,
              fontSize: 17,
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 450.ms),
          const SizedBox(height: 18),
          HealthStatusStrip(
            profile: widget.profile,
            reports: widget.existingReports,
            onTap: widget.onOpenPlan,
          ),
          const SizedBox(height: 22),
          UploadZone(onPick: _pickAndAnalyze, busy: _busy)
              .animate()
              .fadeIn(delay: 140.ms, duration: 500.ms)
              .slideY(begin: 0.05, end: 0),
          const SizedBox(height: 28),
          Text(l10n.howItWorks, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _StepCard(
            step: '1',
            title: l10n.stepUploadTitle,
            body: l10n.stepUploadBody,
            icon: Icons.file_upload_outlined,
          ),
          _StepCard(
            step: '2',
            title: l10n.stepUnderstandTitle,
            body: l10n.stepUnderstandBody,
            icon: Icons.visibility_outlined,
          ),
          _StepCard(
            step: '3',
            title: l10n.stepActTitle,
            body: l10n.stepActBody,
            icon: Icons.favorite_outline_rounded,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.filesStayOnDevice,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String step;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.tealDark),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$step · $title', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(body, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
