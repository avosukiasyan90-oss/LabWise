import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/medical_report.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/cloud_history_service.dart';
import '../services/activity_controller.dart';
import '../services/activity_store.dart';
import '../services/health_service.dart';
import '../services/history_store.dart';
import '../services/locale_controller.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import 'analyze_screen.dart';
import 'history_screen.dart';
import 'plan_screen.dart';
import 'profile_screen.dart';
import 'profile_setup_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.user,
    required this.authService,
    required this.localStore,
    required this.cloudHistory,
    required this.profileService,
    required this.localeController,
    required this.activityStore,
  });

  final User user;
  final AuthService authService;
  final HistoryStore localStore;
  final CloudHistoryService cloudHistory;
  final ProfileService profileService;
  final LocaleController localeController;
  final ActivityStore activityStore;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final _activityController = ActivityController(
    healthService: HealthService(),
    store: widget.activityStore,
  );
  int _index = 0;
  List<MedicalReport> _reports = [];
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);

    final profile = await widget.profileService.loadForUser(widget.user);
    if (mounted) setState(() => _profile = profile);

    try {
      await widget.cloudHistory.ensureUserProfile(
        uid: widget.user.uid,
        email: widget.user.email,
        displayName: widget.user.displayName,
        photoUrl: widget.user.photoURL,
      );

      // Preserve local-only reports, then prefer cloud as source of truth.
      final localSnapshot = List<MedicalReport>.from(widget.localStore.load());
      var reports =
          await widget.cloudHistory.loadReports(widget.user.uid);
      final cloudIds = reports.map((r) => r.id).toSet();
      for (final report in localSnapshot) {
        if (!cloudIds.contains(report.id)) {
          reports = await widget.cloudHistory.addReport(
            uid: widget.user.uid,
            report: report,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _reports = reports;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reports = widget.localStore.load();
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).cloudSyncFailed)),
      );
    }

    if (!mounted) return;
    if (_profile?.hasOnboarded == false) {
      await _openSetup();
    }
  }

  Future<void> _openSetup() async {
    final profile = _profile;
    if (profile == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProfileSetupScreen(
          profile: profile,
          onSave: _saveProfile,
          onSkip: () async {
            final saved = await widget.profileService.markOnboarded(profile);
            if (mounted) setState(() => _profile = saved);
          },
        ),
      ),
    );
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final saved = await widget.profileService.save(profile);
    if (!mounted) return;
    setState(() => _profile = saved);
  }

  Future<void> _saveReport(MedicalReport report, {String? replacing}) async {
    if (replacing != null) {
      final old = _reports.where((r) => r.id == replacing);
      if (old.isNotEmpty) {
        await widget.cloudHistory.removeReport(
          uid: widget.user.uid,
          report: old.first,
        );
      }
    }

    final next = await widget.cloudHistory.addReport(
      uid: widget.user.uid,
      report: report,
    );
    setState(() => _reports = next);
  }

  Future<void> _deleteReport(String id) async {
    final existing = _reports.where((r) => r.id == id);
    if (existing.isEmpty) return;
    final next = await widget.cloudHistory.removeReport(
      uid: widget.user.uid,
      report: existing.first,
    );
    setState(() => _reports = next);
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppL10n.of(ctx);
        return AlertDialog(
          title: Text(l10n.signOutQuestion),
          content: Text(l10n.signOutBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.signOut),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await widget.authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final name =
        widget.user.displayName ?? widget.user.email ?? l10n.googleAccount;
    final profile = _profile ??
        UserProfile(
          uid: widget.user.uid,
          email: widget.user.email,
          displayName: widget.user.displayName,
          photoUrl: widget.user.photoURL,
        );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEAF5F1),
              AppColors.mist,
              Color(0xFFF7F3EC),
            ],
            stops: [0, 0.45, 1],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _index = 3),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.mint,
                              backgroundImage: widget.user.photoURL != null
                                  ? NetworkImage(widget.user.photoURL!)
                                  : null,
                              child: widget.user.photoURL == null
                                  ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : 'L',
                                      style: const TextStyle(
                                        color: AppColors.tealDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.signOut,
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _index,
                      children: [
                        AnalyzeScreen(
                          onReportSaved: _saveReport,
                          existingReports: _reports,
                          profile: profile,
                          onOpenHistory: () => setState(() => _index = 1),
                          onOpenPlan: () => setState(() => _index = 2),
                        ),
                        HistoryScreen(
                          reports: _reports,
                          onDelete: _deleteReport,
                        ),
                        PlanScreen(
                          profile: profile,
                          reports: _reports,
                          activityController: _activityController,
                          onOpenProfile: () => setState(() => _index = 3),
                        ),
                        ProfileScreen(
                          profile: profile,
                          onSave: _saveProfile,
                          onSignOut: _signOut,
                          localeController: widget.localeController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.biotech_outlined),
            selectedIcon: const Icon(Icons.biotech_rounded),
            label: l10n.tabAnalyze,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _reports.isNotEmpty,
              label: Text('${_reports.length}'),
              child: const Icon(Icons.history_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _reports.isNotEmpty,
              label: Text('${_reports.length}'),
              child: const Icon(Icons.history_rounded),
            ),
            label: l10n.tabHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome_rounded),
            label: l10n.tabPlan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
