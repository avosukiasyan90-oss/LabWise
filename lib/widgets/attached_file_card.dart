import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/medical_report.dart';
import '../services/report_file_store.dart';
import '../theme/app_theme.dart';

class AttachedFileCard extends StatefulWidget {
  const AttachedFileCard({super.key, required this.report});

  final MedicalReport report;

  @override
  State<AttachedFileCard> createState() => _AttachedFileCardState();
}

class _AttachedFileCardState extends State<AttachedFileCard> {
  final _fileStore = ReportFileStore();
  bool _localAvailable = false;
  bool _busy = false;

  bool get _cloudAvailable =>
      widget.report.cloudFileUrl != null &&
      widget.report.cloudFileUrl!.isNotEmpty;

  bool get _available => _localAvailable || _cloudAvailable;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  @override
  void didUpdateWidget(covariant AttachedFileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.report.storedFilePath != widget.report.storedFilePath ||
        oldWidget.report.cloudFileUrl != widget.report.cloudFileUrl) {
      _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    final exists = await _fileStore.exists(widget.report.storedFilePath);
    if (!mounted) return;
    setState(() => _localAvailable = exists);
  }

  Future<void> _download() async {
    if (!_available) {
      _toast(AppL10n.of(context).attachedFileMissing);
      return;
    }

    setState(() => _busy = true);
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin =
          box == null ? null : box.localToGlobal(Offset.zero) & box.size;

      if (_localAvailable && widget.report.storedFilePath != null) {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile(
                widget.report.storedFilePath!,
                name: widget.report.fileName,
              ),
            ],
            subject: widget.report.fileName,
            sharePositionOrigin: origin,
          ),
        );
        return;
      }

      final url = widget.report.cloudFileUrl!;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        final opened = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        if (!opened) {
          throw StateError('download failed');
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final tempPath = '${dir.path}/${widget.report.fileName}';
      final xfile = XFile.fromData(
        response.bodyBytes,
        name: widget.report.fileName,
        mimeType: widget.report.fileName.toLowerCase().endsWith('.pdf')
            ? 'application/pdf'
            : 'application/octet-stream',
      );
      await xfile.saveTo(tempPath);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempPath, name: widget.report.fileName)],
          subject: widget.report.fileName,
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (mounted) _toast(AppL10n.of(context).attachedFileExportFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final isPdf = widget.report.fileName.toLowerCase().endsWith('.pdf');
    final subtitle = !_available
        ? l10n.attachedFileUnavailable
        : _localAvailable
            ? l10n.attachedFileOnDevice
            : l10n.attachedFileSynced;

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
          Text(l10n.attachedFile, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPdf
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
                      widget.report.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (!_available || _busy) ? null : _download,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(_busy ? l10n.preparing : l10n.downloadFile),
            ),
          ),
        ],
      ),
    );
  }
}
