import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/health_details_form.dart';

/// Shown right after sign-up. Everything here is optional.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    super.key,
    required this.profile,
    required this.onSave,
    required this.onSkip,
  });

  final UserProfile profile;
  final Future<void> Function(UserProfile profile) onSave;
  final Future<void> Function() onSkip;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<HealthDetailsFormState>();
  late UserProfile _draft = widget.profile;
  bool _busy = false;

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    final error = _formKey.currentState?.validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await widget.onSave(_draft);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.setupSaveFailed)),
      );
    }
  }

  Future<void> _skip() async {
    setState(() => _busy = true);
    try {
      await widget.onSkip();
    } catch (_) {
      // Skipping should never block entry to the app.
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final name = widget.profile.firstName;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF5F1), AppColors.mist, Color(0xFFF7F3EC)],
            stops: [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            children: [
              Text(
                name.isEmpty ? l10n.setupWelcome : l10n.setupWelcomeNamed(name),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 36,
                  color: AppColors.tealDark,
                ),
              )
                  .animate()
                  .fadeIn(duration: 450.ms)
                  .slideY(begin: 0.08, end: 0),
              const SizedBox(height: 10),
              Text(
                l10n.setupBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.muted,
                  fontSize: 17,
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 450.ms),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.line),
                ),
                child: HealthDetailsForm(
                  key: _formKey,
                  profile: widget.profile,
                  onChanged: ({weightKg, heightCm, age, country}) {
                    _draft = UserProfile(
                      uid: widget.profile.uid,
                      email: widget.profile.email,
                      displayName: widget.profile.displayName,
                      photoUrl: widget.profile.photoUrl,
                      weightKg: weightKg,
                      heightCm: heightCm,
                      age: age,
                      country: country,
                    );
                  },
                ),
              ).animate().fadeIn(delay: 140.ms, duration: 500.ms),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.saveAndContinue),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : _skip,
                child: Text(l10n.skipForNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
