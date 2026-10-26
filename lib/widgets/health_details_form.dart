import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'country_picker_sheet.dart';

/// Editable health fields shared by the setup step and the profile screen.
class HealthDetailsForm extends StatefulWidget {
  const HealthDetailsForm({
    super.key,
    required this.profile,
    required this.onChanged,
  });

  final UserProfile profile;

  /// Emits the edited values; nulls mean "not provided".
  final void Function({
    double? weightKg,
    double? heightCm,
    int? age,
    String? country,
  }) onChanged;

  @override
  State<HealthDetailsForm> createState() => HealthDetailsFormState();
}

class HealthDetailsFormState extends State<HealthDetailsForm> {
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late final TextEditingController _age;
  String? _country;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(text: _numberText(widget.profile.weightKg));
    _height = TextEditingController(text: _numberText(widget.profile.heightCm));
    _age = TextEditingController(
      text: widget.profile.age == null ? '' : '${widget.profile.age}',
    );
    _country = widget.profile.country;
  }

  /// Keeps the fields in sync when the saved profile changes underneath us,
  /// e.g. after the values are entered in the sign-up setup step.
  @override
  void didUpdateWidget(covariant HealthDetailsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.profile;
    final current = widget.profile;

    if (previous.weightKg != current.weightKg) {
      _weight.text = _numberText(current.weightKg);
    }
    if (previous.heightCm != current.heightCm) {
      _height.text = _numberText(current.heightCm);
    }
    if (previous.age != current.age) {
      _age.text = current.age == null ? '' : '${current.age}';
    }
    if (previous.country != current.country) {
      setState(() => _country = current.country);
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _age.dispose();
    super.dispose();
  }

  static String _numberText(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  void _emit() {
    widget.onChanged(
      weightKg: double.tryParse(_weight.text.trim().replaceAll(',', '.')),
      heightCm: double.tryParse(_height.text.trim().replaceAll(',', '.')),
      age: int.tryParse(_age.text.trim()),
      country: _country,
    );
  }

  /// Validation message for the current input, or null when acceptable.
  String? validate() {
    final l10n = AppL10n.of(context);
    final weight = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    if (_weight.text.trim().isNotEmpty &&
        (weight == null || weight < 2 || weight > 400)) {
      return l10n.validationWeight;
    }
    final height = double.tryParse(_height.text.trim().replaceAll(',', '.'));
    if (_height.text.trim().isNotEmpty &&
        (height == null || height < 40 || height > 260)) {
      return l10n.validationHeight;
    }
    final age = int.tryParse(_age.text.trim());
    if (_age.text.trim().isNotEmpty && (age == null || age < 1 || age > 120)) {
      return l10n.validationAge;
    }
    return null;
  }

  Future<void> _pickCountry() async {
    final picked = await showCountryPicker(context, selected: _country);
    if (picked == null) return;
    setState(() => _country = picked);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.fieldWeight,
                  suffixText: l10n.unitKg,
                ),
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _height,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.fieldHeight,
                  suffixText: l10n.unitCm,
                ),
                onChanged: (_) => _emit(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _age,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.fieldAge,
            suffixText: l10n.unitYearsOld,
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: _pickCountry,
          borderRadius: BorderRadius.circular(14),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.fieldCountry,
              suffixIcon: const Icon(Icons.expand_more_rounded),
            ),
            child: Text(
              _country ?? l10n.selectCountry,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _country == null ? AppColors.muted : AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
