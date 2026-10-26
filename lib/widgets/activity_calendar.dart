import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../l10n/app_localizations.dart';
import '../models/daily_activity.dart';
import '../services/activity_controller.dart';
import '../services/health_service.dart';
import '../theme/app_theme.dart';

/// Month calendar of movement read from Apple Health or Health Connect, with
/// a detail panel for whichever day is tapped.
class ActivityCalendar extends StatefulWidget {
  const ActivityCalendar({
    super.key,
    required this.controller,
    this.stepGoal,
  });

  final ActivityController controller;
  final int? stepGoal;

  @override
  State<ActivityCalendar> createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<ActivityCalendar> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selected = DailyActivity.dayKey(DateTime.now());

  @override
  void initState() {
    super.initState();
    widget.controller.ensureLoaded();
  }

  DailyActivity? _activityFor(DateTime day) => widget.controller.forDay(day);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final controller = widget.controller;

    if (controller.availability == HealthAvailability.unsupported &&
        !controller.loading) {
      return const SizedBox.shrink();
    }

    if (controller.availability == HealthAvailability.pluginMissing) {
      return _RestartNotice(message: l10n.activityRestartNeeded);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!controller.isReady) ...[
            _ConnectPrompt(
              availability: controller.availability,
              busy: controller.connecting,
              onConnect: controller.connect,
            ),
          ] else ...[
            _buildCalendar(context),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _DayDetail(
                key: ValueKey(_selected),
                day: _selected,
                activity: _activityFor(_selected),
                stepGoal: widget.stepGoal,
              ),
            ),
          ],
          if (controller.loading) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                l10n.activityLoading,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();

    return TableCalendar<DailyActivity>(
      locale: locale,
      firstDay: DateTime(now.year - 2, now.month, 1),
      lastDay: DateTime(now.year, now.month + 1, 0),
      focusedDay: _focusedMonth,
      currentDay: DailyActivity.dayKey(now),
      selectedDayPredicate: (day) => isSameDay(day, _selected),
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.horizontalSwipe,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: theme.textTheme.titleLarge ?? const TextStyle(),
        leftChevronIcon:
            const Icon(Icons.chevron_left_rounded, color: AppColors.tealDark),
        rightChevronIcon:
            const Icon(Icons.chevron_right_rounded, color: AppColors.tealDark),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
        weekendStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
      ),
      calendarStyle: const CalendarStyle(outsideDaysVisible: false),
      onDaySelected: (selected, focused) {
        setState(() {
          _selected = DailyActivity.dayKey(selected);
          _focusedMonth = focused;
        });
      },
      onPageChanged: (focused) {
        setState(() => _focusedMonth = focused);
        widget.controller.loadMonth(focused);
      },
      calendarBuilders: CalendarBuilders<DailyActivity>(
        defaultBuilder: (context, day, _) => _DayCell(
          day: day,
          activity: _activityFor(day),
          stepGoal: widget.stepGoal,
        ),
        todayBuilder: (context, day, _) => _DayCell(
          day: day,
          activity: _activityFor(day),
          stepGoal: widget.stepGoal,
          isToday: true,
        ),
        selectedBuilder: (context, day, _) => _DayCell(
          day: day,
          activity: _activityFor(day),
          stepGoal: widget.stepGoal,
          isSelected: true,
        ),
      ),
    );
  }
}

/// A single date: a ring that fills with the share of the step goal reached,
/// tinted by whichever activity dominated the day.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.activity,
    required this.stepGoal,
    this.isToday = false,
    this.isSelected = false,
  });

  final DateTime day;
  final DailyActivity? activity;
  final int? stepGoal;
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = activity;
    final goal = (stepGoal ?? 8000).clamp(1000, 30000);
    final progress =
        data == null ? 0.0 : (data.steps / goal).clamp(0.0, 1.0).toDouble();
    final tone = _toneFor(data);

    return Container(
      margin: const EdgeInsets.all(3),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (progress > 0)
            SizedBox(
              width: 36,
              height: 36,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: 600.ms,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 3,
                  backgroundColor: AppColors.mist,
                  valueColor: AlwaysStoppedAnimation(tone),
                ),
              ),
            ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.tealDark
                  : isToday
                      ? AppColors.mint
                      : Colors.transparent,
            ),
            child: Text(
              '${day.day}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.ink,
                fontWeight:
                    isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _toneFor(DailyActivity? data) {
    if (data == null) return AppColors.mist;
    if (data.cycleKm > data.walkRunKm) return AppColors.amber;
    if (data.sessions.any((s) => s.kind == ActivityKind.running)) {
      return AppColors.coral;
    }
    return AppColors.sage;
  }
}

/// Everything recorded on the tapped day.
class _DayDetail extends StatelessWidget {
  const _DayDetail({
    super.key,
    required this.day,
    required this.activity,
    required this.stepGoal,
  });

  final DateTime day;
  final DailyActivity? activity;
  final int? stepGoal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final data = activity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, d MMMM', locale).format(day),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        if (data == null || data.isEmpty)
          Row(
            children: [
              const Icon(Icons.bedtime_outlined,
                  size: 18, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.activityNoneRecorded,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          )
        else ...[
          Row(
            children: [
              _Stat(
                icon: Icons.directions_walk_rounded,
                value: '${data.steps}',
                label: l10n.metricSteps,
              ),
              const SizedBox(width: 8),
              _Stat(
                icon: Icons.straighten_rounded,
                value: '${data.totalKm.toStringAsFixed(1)} km',
                label: l10n.activityDistance,
              ),
              const SizedBox(width: 8),
              _Stat(
                icon: Icons.timer_outlined,
                value: '${data.activeMinutes}',
                label: l10n.activityMinutes,
              ),
              const SizedBox(width: 8),
              _Stat(
                icon: Icons.local_fire_department_outlined,
                value: '${data.activeKcal}',
                label: l10n.metricKcal,
              ),
            ],
          ),
          if (data.walkRunKm > 0 || data.cycleKm > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (data.walkRunKm > 0)
                  _Breakdown(
                    icon: Icons.directions_walk_rounded,
                    label: l10n.activityWalkRun,
                    value: '${data.walkRunKm.toStringAsFixed(1)} km',
                    tone: AppColors.sage,
                  ),
                if (data.walkRunKm > 0 && data.cycleKm > 0)
                  const SizedBox(width: 8),
                if (data.cycleKm > 0)
                  _Breakdown(
                    icon: Icons.directions_bike_rounded,
                    label: l10n.activityCycling,
                    value: '${data.cycleKm.toStringAsFixed(1)} km',
                    tone: AppColors.amber,
                  ),
              ],
            ),
          ],
          if (data.sessions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(l10n.activitySessions, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...data.sessions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SessionRow(session: s),
              ),
            ),
          ],
        ],
      ],
    ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.04, end: 0);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.tealDark),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(value, style: theme.textTheme.titleMedium),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: tone),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: theme.textTheme.titleMedium),
                  Text(label, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});

  final ActivitySession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final name = switch (session.kind) {
      ActivityKind.walking => l10n.activityKindWalking,
      ActivityKind.running => l10n.activityKindRunning,
      ActivityKind.cycling => l10n.activityKindCycling,
      ActivityKind.other => l10n.activityKindOther,
    };

    final parts = <String>[
      DateFormat.Hm(locale).format(session.start),
      l10n.activityDurationMinutes(session.duration.inMinutes),
      if (session.km != null) '${session.km!.toStringAsFixed(1)} km',
      if (session.kcal != null) '${session.kcal} kcal',
    ];

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(session.kind.icon, size: 18, color: AppColors.tealDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
              Text(parts.join(' · '), style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown until the user grants access to their health store.
class _ConnectPrompt extends StatelessWidget {
  const _ConnectPrompt({
    required this.availability,
    required this.busy,
    required this.onConnect,
  });

  final HealthAvailability availability;
  final bool busy;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final needsInstall = availability == HealthAvailability.needsHealthConnect;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: AppColors.tealDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.activityConnectTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            needsInstall
                ? l10n.activityHealthConnectBody
                : l10n.activityConnectBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: busy ? null : onConnect,
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.link_rounded),
              label: Text(
                needsInstall
                    ? l10n.activityInstallHealthConnect
                    : l10n.activityConnectButton,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Debug-time hint for the one failure the user cannot fix from inside the
/// app: a plugin added after this binary was built.
class _RestartNotice extends StatelessWidget {
  const _RestartNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.restart_alt_rounded, color: AppColors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
