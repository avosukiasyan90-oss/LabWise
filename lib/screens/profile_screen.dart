import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../services/locale_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/health_details_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onSave,
    required this.onSignOut,
    required this.localeController,
  });

  final UserProfile profile;
  final Future<void> Function(UserProfile profile) onSave;
  final Future<void> Function() onSignOut;
  final LocaleController localeController;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<HealthDetailsFormState>();
  late UserProfile _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.profile;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _draft = widget.profile;
    }
  }

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    final error = _formKey.currentState?.validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(_draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSaved)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final profile = widget.profile;
    final bmi = _draft.bmi;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            l10n.profileTitle,
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 36),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.06, end: 0),
          const SizedBox(height: 6),
          Text(
            l10n.profileSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.mint,
                      backgroundImage: profile.photoUrl != null
                          ? NetworkImage(profile.photoUrl!)
                          : null,
                      child: profile.photoUrl == null
                          ? Text(
                              (profile.displayName ?? profile.email ?? 'L')
                                  .characters
                                  .first
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.tealDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName ?? l10n.googleAccount,
                            style: theme.textTheme.titleLarge,
                          ),
                          if (profile.email != null)
                            Text(
                              profile.email!,
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ReadOnlyRow(label: l10n.fieldName, value: profile.firstName),
                _ReadOnlyRow(label: l10n.fieldSurname, value: profile.surname),
                _ReadOnlyRow(
                  label: l10n.fieldEmail,
                  value: profile.email ?? '—',
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.managedByGoogle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 450.ms),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.healthDetails, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  l10n.updateAnytime,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                HealthDetailsForm(
                  key: _formKey,
                  profile: profile,
                  onChanged: ({weightKg, heightCm, age, country}) {
                    setState(() {
                      _draft = UserProfile(
                        uid: profile.uid,
                        email: profile.email,
                        displayName: profile.displayName,
                        photoUrl: profile.photoUrl,
                        weightKg: weightKg,
                        heightCm: heightCm,
                        age: age,
                        country: country,
                        onboardedAt: profile.onboardedAt,
                      );
                    });
                  },
                ),
                if (bmi != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.bmiNote(bmi.toStringAsFixed(1)),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.save),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 140.ms, duration: 450.ms),
          const SizedBox(height: 14),
          _LanguageCard(controller: widget.localeController)
              .animate()
              .fadeIn(delay: 180.ms, duration: 450.ms),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout_rounded),
            label: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.controller});

  final LocaleController controller;

  String _label(AppL10n l10n, AppLanguage language) => switch (language) {
        AppLanguage.english => l10n.languageEnglish,
        AppLanguage.russian => l10n.languageRussian,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language_rounded, color: AppColors.tealDark),
              const SizedBox(width: 10),
              Text(l10n.language, style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.languageSubtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final language in AppLanguage.values)
                  ChoiceChip(
                    label: Text(_label(l10n, language)),
                    selected: controller.language == language,
                    onSelected: (_) => controller.setLanguage(language),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
