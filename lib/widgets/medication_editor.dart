import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/medication.dart';
import '../theme/app_theme.dart';
import 'dose_time_picker.dart';

/// Bottom sheet for adding or editing a medicine.
///
/// Pops with the saved [Medication], or null when dismissed.
class MedicationEditor extends StatefulWidget {
  const MedicationEditor({super.key, this.existing});

  final Medication? existing;

  @override
  State<MedicationEditor> createState() => _MedicationEditorState();
}

class _MedicationEditorState extends State<MedicationEditor> {
  static const _uuid = Uuid();

  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.existing?.notes ?? '');

  late int _count = widget.existing?.count ?? 1;
  late MedicationFrequency _frequency =
      widget.existing?.frequency ?? MedicationFrequency.daily;
  late List<DoseTime> _times = [
    ...?widget.existing?.times,
    if (widget.existing == null) const DoseTime(hour: 9, minute: 0),
  ];
  late DateTime _start = widget.existing?.startDate ?? DateTime.now();
  late DateTime? _end = widget.existing?.endDate;

  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final name = _title.text.trim();
    final l10n = AppL10n.of(context);

    if (name.isEmpty) {
      setState(() => _error = l10n.medsNeedsName);
      return;
    }
    if (_times.isEmpty && _frequency != MedicationFrequency.asNeeded) {
      setState(() => _error = l10n.medsNeedsTime);
      return;
    }

    final sorted = [..._times]..sort();
    final medication = Medication(
      id: widget.existing?.id ?? _uuid.v4(),
      title: name,
      count: _count,
      times: sorted,
      frequency: _frequency,
      startDate: _start,
      endDate: _end,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      takenKeys: widget.existing?.takenKeys ?? const {},
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(medication);
  }

  Future<void> _addTime() async {
    final picked = await showDoseTimePicker(
      context,
      taken: _times.toSet(),
    );
    if (picked == null) return;
    setState(() {
      _times = [..._times, picked]..sort();
      _error = null;
    });
  }

  /// Tapping an existing chip reopens the picker on that value.
  Future<void> _editTime(DoseTime existing) async {
    final picked = await showDoseTimePicker(
      context,
      initial: existing,
      taken: _times.toSet(),
    );
    if (picked == null || picked == existing) return;
    setState(() {
      _times = [..._times.where((t) => t != existing), picked]..sort();
      _error = null;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? _start : (_end ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final insets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
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
              const SizedBox(height: 18),
              Text(
                widget.existing == null ? l10n.medsAdd : l10n.medsEdit,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.medsFieldName,
                  hintText: l10n.medsFieldNameHint,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.medsFieldCount,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  _Stepper(
                    value: _count,
                    onChanged: (v) => setState(() => _count = v),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(l10n.medsFieldFrequency, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MedicationFrequency.values
                    .map(
                      (f) => ChoiceChip(
                        label: Text(_frequencyLabel(l10n, f)),
                        selected: _frequency == f,
                        onSelected: (_) => setState(() => _frequency = f),
                      ),
                    )
                    .toList(),
              ),
              if (_frequency != MedicationFrequency.asNeeded) ...[
                const SizedBox(height: 18),
                Text(l10n.medsFieldTimes, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._times.map(
                      (time) => InputChip(
                        label: Text(
                          DateFormat.Hm(locale).format(time.on(DateTime.now())),
                        ),
                        onPressed: () => _editTime(time),
                        onDeleted: () =>
                            setState(() => _times = [..._times]..remove(time)),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add_rounded, size: 17),
                      label: Text(l10n.medsAddTime),
                      onPressed: _addTime,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: l10n.medsFieldStart,
                      value: DateFormat.yMMMd(locale).format(_start),
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField(
                      label: l10n.medsFieldEnd,
                      value: _end == null
                          ? l10n.medsNoEnd
                          : DateFormat.yMMMd(locale).format(_end!),
                      onTap: () => _pickDate(isStart: false),
                      onClear: _end == null
                          ? null
                          : () => setState(() => _end = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _notes,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.medsFieldNotes),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.coral),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(l10n.medsSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _frequencyLabel(AppL10n l10n, MedicationFrequency f) =>
      switch (f) {
        MedicationFrequency.daily => l10n.medsFrequencyDaily,
        MedicationFrequency.everyOtherDay => l10n.medsFrequencyEveryOther,
        MedicationFrequency.weekly => l10n.medsFrequencyWeekly,
        MedicationFrequency.asNeeded => l10n.medsFrequencyAsNeeded,
      };
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value <= 1
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onChanged(value - 1);
                  },
            icon: const Icon(Icons.remove_rounded, size: 18),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            onPressed: value >= 20
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onChanged(value + 1);
                  },
            icon: const Icon(Icons.add_rounded, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
