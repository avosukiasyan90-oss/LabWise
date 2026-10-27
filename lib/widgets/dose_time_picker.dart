import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/medication.dart';
import '../theme/app_theme.dart';

/// Asks for a reminder time. Returns null if dismissed.
///
/// Replaces the Material dial, which is slow and imprecise for something the
/// user may set four times per medicine. Most doses land on one of a handful
/// of everyday times, so those are one tap, and the wheel handles the rest.
Future<DoseTime?> showDoseTimePicker(
  BuildContext context, {
  DoseTime? initial,
  Set<DoseTime> taken = const {},
}) {
  return showModalBottomSheet<DoseTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DoseTimeSheet(initial: initial, taken: taken),
  );
}

class _DoseTimeSheet extends StatefulWidget {
  const _DoseTimeSheet({this.initial, this.taken = const {}});

  final DoseTime? initial;

  /// Times already on this medicine, shown as unavailable rather than
  /// silently refused after the user commits.
  final Set<DoseTime> taken;

  @override
  State<_DoseTimeSheet> createState() => _DoseTimeSheetState();
}

class _DoseTimeSheetState extends State<_DoseTimeSheet> {
  static const _presets = <(String Function(AppL10n), DoseTime)>[
    (_morning, DoseTime(hour: 8, minute: 0)),
    (_midday, DoseTime(hour: 13, minute: 0)),
    (_evening, DoseTime(hour: 19, minute: 0)),
    (_night, DoseTime(hour: 22, minute: 0)),
  ];

  static String _morning(AppL10n l) => l.doseTimeMorning;
  static String _midday(AppL10n l) => l.doseTimeMidday;
  static String _evening(AppL10n l) => l.doseTimeEvening;
  static String _night(AppL10n l) => l.doseTimeNight;

  late DoseTime _selected = _initialSelection();

  /// Opening on a time the medicine already uses would show a warning and a
  /// disabled button before the user has touched anything, so fall through to
  /// the first free preset instead.
  DoseTime _initialSelection() {
    final initial = widget.initial;
    if (initial != null) return initial;

    for (final preset in _presets) {
      if (!widget.taken.contains(preset.$2)) return preset.$2;
    }
    return const DoseTime(hour: 8, minute: 0);
  }

  void _pick(DoseTime time) {
    HapticFeedback.selectionClick();
    setState(() => _selected = time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    final clash = widget.taken.contains(_selected) && _selected != widget.initial;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.doseTimeTitle,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                Text(
                  DateFormat.Hm(locale).format(_selected.on(DateTime.now())),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: AppColors.tealDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.doseTimeQuick, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final preset in _presets) ...[
                  Expanded(
                    child: _PresetButton(
                      label: preset.$1(l10n),
                      time: preset.$2,
                      locale: locale,
                      selected: _selected == preset.$2,
                      disabled: widget.taken.contains(preset.$2) &&
                          preset.$2 != widget.initial,
                      onTap: () => _pick(preset.$2),
                    ),
                  ),
                  if (preset != _presets.last) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 170,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle:
                        theme.textTheme.titleLarge ?? const TextStyle(),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: use24h,
                  minuteInterval: 5,
                  initialDateTime: _roundToInterval(
                    _selected.on(DateTime.now()),
                  ),
                  onDateTimeChanged: (value) => setState(
                    () => _selected =
                        DoseTime(hour: value.hour, minute: value.minute),
                  ),
                ),
              ),
            ),
            if (clash) ...[
              const SizedBox(height: 6),
              Text(
                l10n.doseTimeAlready,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.coral),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    clash ? null : () => Navigator.of(context).pop(_selected),
                child: Text(l10n.doseTimeSet),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The wheel steps in five-minute jumps, so it must open on a value it can
  /// actually represent or it snaps and reports a different time than shown.
  static DateTime _roundToInterval(DateTime value) {
    final rounded = (value.minute / 5).round() * 5;
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour + (rounded == 60 ? 1 : 0),
      rounded == 60 ? 0 : rounded,
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.time,
    required this.locale,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final DoseTime time;
  final String locale;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = selected ? AppColors.tealDark : Colors.white;
    final foreground = selected
        ? Colors.white
        : disabled
            ? AppColors.muted
            : AppColors.ink;

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.tealDark : AppColors.line,
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat.Hm(locale).format(time.on(DateTime.now())),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: foreground,
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
