import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authService,
    this.onSignedIn,
  });

  final AuthService authService;
  final VoidCallback? onSignedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum _Pending { none, google, apple }

class _AuthScreenState extends State<AuthScreen> {
  _Pending _pending = _Pending.none;
  String? _error;
  bool _appleAvailable = false;

  bool get _busy => _pending != _Pending.none;

  @override
  void initState() {
    super.initState();
    _checkApple();
  }

  Future<void> _checkApple() async {
    final available = await widget.authService.isAppleSignInAvailable;
    if (mounted) setState(() => _appleAvailable = available);
  }

  Future<void> _signIn(_Pending which) async {
    final l10n = AppL10n.of(context);
    setState(() {
      _pending = which;
      _error = null;
    });
    try {
      if (which == _Pending.google) {
        await widget.authService.signInWithGoogle();
      } else {
        await widget.authService.signInWithApple();
      }
      widget.onSignedIn?.call();
    } catch (e) {
      final detail = e.toString().replaceFirst('Bad state: ', '');
      final label = which == _Pending.google ? 'Google' : 'Apple';
      setState(() {
        _error = detail.startsWith('Sign-in was canceled')
            ? l10n.signInCanceled
            : l10n.signInFailed(label, detail);
      });
    } finally {
      if (mounted) setState(() => _pending = _Pending.none);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEAF5F1),
              AppColors.mist,
              Color(0xFFF7F3EC),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontSize: 44,
                    color: AppColors.tealDark,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: 0.08, end: 0),
                const SizedBox(height: 10),
                Text(
                  l10n.authTagline,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.muted,
                    fontSize: 17,
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 450.ms),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.08),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.authWelcome, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authExplainer,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed:
                              _busy ? null : () => _signIn(_Pending.google),
                          icon: _pending == _Pending.google
                              ? const _ButtonSpinner()
                              : const Icon(Icons.g_mobiledata_rounded, size: 28),
                          label: Text(
                            _pending == _Pending.google
                                ? l10n.signingIn
                                : l10n.continueWithGoogle,
                          ),
                        ),
                      ),
                      if (_appleAvailable) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  Colors.black.withValues(alpha: 0.4),
                              disabledForegroundColor:
                                  Colors.white.withValues(alpha: 0.7),
                            ),
                            onPressed:
                                _busy ? null : () => _signIn(_Pending.apple),
                            icon: _pending == _Pending.apple
                                ? const _ButtonSpinner()
                                : const Icon(Icons.apple, size: 26),
                            label: Text(
                              _pending == _Pending.apple
                                  ? l10n.signingIn
                                  : l10n.continueWithApple,
                            ),
                          ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.coral,
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 140.ms, duration: 500.ms),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    l10n.authPrivacyNote,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
