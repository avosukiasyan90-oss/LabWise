import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication.dart';
import 'app_log.dart';

/// Called when the user taps a reminder, identifying the exact dose.
typedef DoseTapCallback = void Function(String medicationId, DateTime at);

/// Schedules the local reminders for medication doses.
///
/// Everything here is best-effort: a reminder failing to schedule must never
/// stop the user from saving a medication, so each call is guarded and logged
/// rather than thrown.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'medication_reminders';
  static const _channelName = 'Medication reminders';
  static const _channelDescription =
      'Reminds you when a dose is due.';

  /// How far ahead to materialise reminders. Local notifications have per-app
  /// limits (64 pending on iOS), so a rolling window is scheduled and topped
  /// up on each launch rather than scheduling a whole course at once.
  static const int horizonDays = 14;
  static const int maxPending = 60;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// Invoked when a reminder is tapped. Tapping means "I have taken it".
  DoseTapCallback? onDoseTap;

  /// Encodes which dose a reminder refers to, so a tap can mark that exact
  /// one rather than guessing from the current time.
  static String encodePayload(String medicationId, DateTime at) =>
      '$medicationId|${Medication.doseKey(at)}';

  /// Returns null for anything that is not a dose payload.
  static ({String medicationId, DateTime at})? decodePayload(String? payload) {
    if (payload == null) return null;
    final separator = payload.lastIndexOf('|');
    if (separator <= 0) return null;

    final id = payload.substring(0, separator);
    final stamp = payload.substring(separator + 1);
    final at = DateTime.tryParse(stamp);
    if (id.isEmpty || at == null) return null;
    return (medicationId: id, at: at);
  }

  Future<bool> initialize() async {
    if (_ready) return true;
    try {
      tzdata.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));

      await _plugin.initialize(
        onDidReceiveNotificationResponse: _handleResponse,
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            // Permission is requested explicitly later, when the user adds
            // their first scheduled medicine.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
      AppLog.app.debug('Notifications initialised', {'tz': name.identifier});
      return true;
    } catch (e) {
      AppLog.app.error('Notification init failed', error: e);
      return false;
    }
  }

  void _handleResponse(NotificationResponse response) {
    final dose = decodePayload(response.payload);
    if (dose == null) return;
    AppLog.app.info('Reminder tapped', {'at': dose.at.toString()});
    onDoseTap?.call(dose.medicationId, dose.at);
  }

  /// The reminder that launched the app from a terminated state, if any.
  ///
  /// [initialize] cannot deliver this through the normal callback because the
  /// tap happened before the handler existed.
  Future<void> consumeLaunchPayload() async {
    if (!await initialize()) return;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp != true) return;
      final dose = decodePayload(details?.notificationResponse?.payload);
      if (dose == null) return;
      AppLog.app.info('Launched from a reminder');
      onDoseTap?.call(dose.medicationId, dose.at);
    } catch (e) {
      AppLog.app.warn('Could not read launch reminder', {'error': e});
    }
  }

  /// Asks for permission. Safe to call repeatedly; the OS only prompts once.
  Future<bool> requestPermission() async {
    if (!await initialize()) return false;

    try {
      if (Platform.isIOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        AppLog.app.info('Notification permission', {'granted': granted});
        return granted ?? false;
      }

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      // Exact alarms are a separate grant on Android 12+.
      await android?.requestExactAlarmsPermission();
      AppLog.app.info('Notification permission', {'granted': granted});
      return granted ?? false;
    } catch (e) {
      AppLog.app.error('Permission request failed', error: e);
      return false;
    }
  }

  Future<bool> hasPermission() async {
    if (!await initialize()) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.areNotificationsEnabled() ?? false;
      }

      // Ask iOS rather than assuming. Assuming "granted" here meant the app
      // never prompted, so reminders silently never fired.
      final options = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return options?.isEnabled ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Rebuilds the pending reminders from scratch for the whole list.
  ///
  /// Called after any change, which is simpler and less error-prone than
  /// tracking individual notification ids as doses are edited.
  Future<void> rescheduleAll(List<Medication> medications) async {
    if (!await initialize()) return;

    try {
      await _plugin.cancelAll();
    } catch (e) {
      AppLog.app.warn('Could not clear reminders', {'error': e});
      return;
    }

    final now = DateTime.now();
    final pending = <({DateTime at, Medication medication})>[];

    for (final medication in medications) {
      if (!medication.isScheduled || medication.hasEnded) continue;

      for (var offset = 0; offset <= horizonDays; offset++) {
        final day = now.add(Duration(days: offset));
        for (final dose in medication.dosesOn(day)) {
          if (dose.taken) continue;
          if (!dose.at.isAfter(now)) continue;
          pending.add((at: dose.at, medication: medication));
        }
      }
    }

    pending.sort((a, b) => a.at.compareTo(b.at));

    var scheduled = 0;
    for (final entry in pending.take(maxPending)) {
      final ok = await _schedule(
        id: _idFor(entry.medication.id, entry.at),
        at: entry.at,
        title: entry.medication.title,
        body: _body(entry.medication),
        payload: encodePayload(entry.medication.id, entry.at),
      );
      if (ok) scheduled++;
    }

    AppLog.app.success('Reminders scheduled', {
      'count': scheduled,
      'candidates': pending.length,
      'queuedByOs': await pendingCount(),
    });
  }

  /// How many reminders iOS or Android currently has queued for us.
  ///
  /// Useful as ground truth when reminders appear not to fire: a count of
  /// zero means scheduling failed, anything else means the OS has them.
  Future<int> pendingCount() async {
    if (!await initialize()) return 0;
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.length;
    } catch (e) {
      AppLog.app.warn('Could not read pending reminders', {'error': e});
      return 0;
    }
  }

  Future<void> cancelAll() async {
    if (!await initialize()) return;
    try {
      await _plugin.cancelAll();
      AppLog.app.debug('Reminders cleared');
    } catch (e) {
      AppLog.app.warn('Could not clear reminders', {'error': e});
    }
  }

  Future<bool> _schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      return true;
    } catch (e) {
      AppLog.app.warn('Reminder not scheduled', {'at': at.toString(), 'error': e});
      return false;
    }
  }

  static String _body(Medication medication) {
    final count = medication.count;
    return count > 1 ? 'Time to take $count' : 'Time to take it';
  }

  /// Deterministic id so the same dose always maps to the same notification.
  static int _idFor(String medicationId, DateTime at) {
    final composed = '$medicationId|${Medication.doseKey(at)}';
    // 31-bit positive hash: Android notification ids must fit in an int.
    return composed.hashCode & 0x7fffffff;
  }
}
