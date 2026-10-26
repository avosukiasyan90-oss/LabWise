import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/cloud_history_service.dart';
import 'services/activity_store.dart';
import 'services/history_store.dart';
import 'services/locale_controller.dart';
import 'services/profile_service.dart';
import 'services/session_token_store.dart';
import 'theme/app_theme.dart';
import 'services/app_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  var firebaseReady = false;
  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseReady = true;
      AppLog.app.success('Firebase ready');
    } catch (e) {
      AppLog.app.error('Firebase init failed', error: e);
    }
  }

  final localStore = await HistoryStore.create();
  final sessionStore = await SessionTokenStore.create();
  final authService = AuthService(sessionStore: sessionStore);
  final cloudHistory = CloudHistoryService(local: localStore);
  final profileService = ProfileService();
  final localeController = await LocaleController.load();
  final activityStore = await ActivityStore.create();

  if (firebaseReady) {
    try {
      await authService.restoreSession();
    } catch (e) {
      AppLog.auth.warn('Session restore skipped', {'error': e});
    }
  }

  runApp(
    LabWiseApp(
      authService: authService,
      localStore: localStore,
      cloudHistory: cloudHistory,
      profileService: profileService,
      localeController: localeController,
      activityStore: activityStore,
      firebaseReady: firebaseReady,
    ),
  );
}

class LabWiseApp extends StatelessWidget {
  const LabWiseApp({
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
    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) => MaterialApp(
        title: 'LabWise Health',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: localeController.locale,
        supportedLocales: AppL10n.supportedLocales,
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: AuthGate(
          authService: authService,
          localStore: localStore,
          cloudHistory: cloudHistory,
          profileService: profileService,
          localeController: localeController,
          activityStore: activityStore,
          firebaseReady: firebaseReady,
        ),
      ),
    );
  }
}
