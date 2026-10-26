import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class UploadZone extends StatelessWidget {
  const UploadZone({
    super.key,
    required this.onPick,
    this.busy = false,
  });

  final VoidCallback onPick;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onPick,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE7F5F1),
                Color(0xFFF7F3EC),
                Color(0xFFDDEEEA),
              ],
            ),
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.28), width: 1.5),
          ),
          child: busy
              ? Column(
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.readingReport,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.readingReportSubtitle,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.upload_file_rounded,
                        size: 34,
                        color: AppColors.teal,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 0, end: -4, duration: 1600.ms, curve: Curves.easeInOut),
                    const SizedBox(height: 20),
                    Text(
                      l10n.uploadTitle,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                      Text(
                      l10n.uploadSubtitle,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: onPick,
                      icon: const Icon(Icons.folder_open_rounded),
                      label: Text(l10n.chooseFile),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
