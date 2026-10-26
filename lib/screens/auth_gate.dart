import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/cloud_history_service.dart';
import '../services/activity_store.dart';
import '../services/history_store.dart';
import '../services/locale_controller.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'home_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.localStore,
    required this.cloudHistory,
    required this.profileService,
    required this.localeController,
    required this.activityStore,
    required this.firebaseReady,
  });

  final AuthService authService;
  final HistoryStore localStore;
  final CloudHistoryService cloudHistory;
  final ProfileService profileService;
  final LocaleController localeController;
  final ActivityStore activityStore;
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady || !DefaultFirebaseOptions.isConfigured) {
      return const _FirebaseSetupScreen();
    }

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return AuthScreen(authService: authService);
        }

        return HomeShell(
          key: ValueKey(user.uid),
          user: user,
          authService: authService,
          localStore: localStore,
          cloudHistory: cloudHistory,
          profileService: profileService,
          localeController: localeController,
          activityStore: activityStore,
        );
      },
    );
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF5F1), AppColors.mist],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.appTitle, style: theme.textTheme.displayMedium),
              const SizedBox(height: 16),
              Text(
                l10n.firebaseNotConfigured,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.firebaseSetupIntro,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  './tool/setup_firebase.sh',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.tealDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.firebaseSetupFooter,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
