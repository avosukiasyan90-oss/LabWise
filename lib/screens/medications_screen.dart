import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/medication.dart';
import '../services/medication_schedule.dart';
import '../theme/app_theme.dart';
import '../widgets/medication_editor.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({
    super.key,
    required this.medications,
    required this.onSave,
    required this.onDelete,
    required this.onToggleDose,
    required this.notificationsAllowed,
    required this.onEnableNotifications,
  });

  final List<Medication> medications;
  final Future<void> Function(Medication medication) onSave;
  final Future<void> Function(String id) onDelete;
  final Future<void> Function(Medication medication, DateTime at, bool taken)
      onToggleDose;
  final bool notificationsAllowed;
  final Future<void> Function() onEnableNotifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    const schedule = MedicationSchedule();
    final ordered = schedule.ordered(medications);
    final (taken, total) = schedule.progressToday(medications);

    final subtitle = total == 0
        ? l10n.medsSubtitleNoneToday
        : taken == total
            ? l10n.medsSubtitleAllDone
            : l10n.medsSubtitlePending(taken, total);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.medsAdd),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Text(
              l10n.medsTitle,
              style: theme.textTheme.displayMedium?.copyWith(fontSize: 36),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            if (!notificationsAllowed && medications.isNotEmpty) ...[
              _NotificationsPrompt(onEnable: onEnableNotifications),
              const SizedBox(height: 14),
            ],
            if (medications.isEmpty)
              const _EmptyMeds()
            else
              ...ordered.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: ValueKey(entry.value.medication.id),
                        direction: DismissDirection.endToStart,
                        background: const _DeleteBackground(),
                        confirmDismiss: (_) =>
                            _confirmDelete(context, entry.value.medication),
                        onDismissed: (_) {},
                        child: _MedicationCard(
                          status: entry.value,
                          onToggleDose: onToggleDose,
                          onEdit: () => _openEditor(
                            context,
                            existing: entry.value.medication,
                          ),
                          onDelete: () =>
                              _confirmDelete(context, entry.value.medication),
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: (50 * entry.key).ms,
                            duration: 320.ms,
                          )
                          .slideY(begin: 0.04, end: 0),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {Medication? existing}) async {
    final saved = await showModalBottomSheet<Medication>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MedicationEditor(existing: existing),
    );
    if (saved != null) await onSave(saved);
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    Medication medication,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppL10n.of(ctx);
        return AlertDialog(
          title: Text(l10n.medsDeleteTitle),
          content: Text(l10n.medsDeleteBody(medication.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.medsDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return false;
    await onDelete(medication.id);
    return true;
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.status,
    required this.onToggleDose,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicationStatus status;
  final Future<void> Function(Medication medication, DateTime at, bool taken)
      onToggleDose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final medication = status.medication;
    final tone = _toneFor(status.state);
    final faded = status.state == DoseState.done ||
        status.state == DoseState.inactive;

    return Opacity(
      opacity: faded ? 0.68 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onEdit,
          onLongPress: onDelete,
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
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.medication_outlined,
                        size: 21,
                        color: tone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _detailLine(l10n, locale),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _stateLabel(l10n),
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: tone, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                if (status.dosesToday.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: status.dosesToday
                        .map(
                          (dose) => _DoseChip(
                            dose: dose,
                            locale: locale,
                            onTap: () => onToggleDose(
                              medication,
                              dose.at,
                              !dose.taken,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _detailLine(AppL10n l10n, String locale) {
    final parts = <String>[l10n.medsDoseCount(status.medication.count)];

    if (!status.medication.isScheduled) {
      parts.add(l10n.medsAsNeededHint);
      return parts.join(' · ');
    }

    final next = status.nextDose;
    if (next != null) {
      final today = DateTime.now();
      final sameDay = next.year == today.year &&
          next.month == today.month &&
          next.day == today.day;
      parts.add(
        sameDay
            ? l10n.medsNextDose(DateFormat.Hm(locale).format(next))
            : l10n.medsNextOn(DateFormat.MMMEd(locale).format(next)),
      );
    }
    return parts.join(' · ');
  }

  String _stateLabel(AppL10n l10n) => switch (status.state) {
        DoseState.overdue => l10n.medsStateOverdue,
        DoseState.dueNow => l10n.medsStateDueNow,
        DoseState.upcoming => l10n.medsStateUpcoming,
        DoseState.done => l10n.medsStateDone,
        DoseState.inactive => l10n.medsStateInactive,
      };

  static Color _toneFor(DoseState state) => switch (state) {
        DoseState.overdue => AppColors.coral,
        DoseState.dueNow => AppColors.amber,
        DoseState.upcoming => AppColors.teal,
        DoseState.done => AppColors.sage,
        DoseState.inactive => AppColors.muted,
      };
}

/// One tappable dose time. Tapping marks it taken, tapping again undoes it.
class _DoseChip extends StatelessWidget {
  const _DoseChip({
    required this.dose,
    required this.locale,
    required this.onTap,
  });

  final Dose dose;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = dose.taken
        ? AppColors.sage
        : dose.isOverdue
            ? AppColors.coral
            : dose.isDueNow
                ? AppColors.amber
                : AppColors.tealDark;

    return Material(
      color: tone.withValues(alpha: dose.taken ? 0.14 : 0.06),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                dose.taken
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 15,
                color: tone,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat.Hm(locale).format(dose.at),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: tone,
                  fontSize: 12,
                  decoration: dose.taken ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsPrompt extends StatelessWidget {
  const _NotificationsPrompt({required this.onEnable});

  final Future<void> Function() onEnable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off_outlined,
              size: 20, color: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.medsNotificationsOffTitle,
                    style: theme.textTheme.titleMedium),
                Text(
                  l10n.medsNotificationsOffBody,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onEnable,
            child: Text(l10n.medsEnableNotifications),
          ),
        ],
      ),
    );
  }
}

class _EmptyMeds extends StatelessWidget {
  const _EmptyMeds();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.medication_outlined,
              size: 38,
              color: AppColors.tealDark,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.04, 1.04),
                duration: 1800.ms,
              ),
          const SizedBox(height: 20),
          Text(l10n.medsEmptyTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l10n.medsEmptyBody,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Revealed as a medication card is dragged left.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_outline_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            l10n.medsDelete,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
