import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/activity_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_calendar.dart';

/// Full-screen activity calendar, pushed from the compact card on the Plan
/// tab so the month grid is not competing with the rest of the plan.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({
    super.key,
    required this.controller,
    this.stepGoal,
  });

  final ActivityController controller;
  final int? stepGoal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        title: Text(l10n.activityTitle),
        backgroundColor: AppColors.mist,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Text(
              l10n.activitySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            ActivityCalendar(controller: controller, stepGoal: stepGoal),
          ],
        ),
      ),
    );
  }
}
