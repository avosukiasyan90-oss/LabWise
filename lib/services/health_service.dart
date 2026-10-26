import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_activity.dart';
import 'app_log.dart';

/// Why the activity calendar has nothing to show.
enum HealthAvailability {
  /// Ready to read, permission granted.
  ready,

  /// The platform supports it but the user has not granted access yet.
  needsPermission,

  /// Android only: Health Connect is not installed or is out of date.
  needsHealthConnect,

  /// The plugin's method channel is missing, which happens when the binary
  /// on the device predates the plugin being added. Only a relaunch fixes it.
  pluginMissing,

  /// Desktop, web, or a platform with no health store.
  unsupported,
}

/// Reads step, distance, and workout history from Apple Health on iOS and
/// Health Connect on Android.
///
/// Every read is wrapped: a missing permission or an unavailable data type
/// degrades to zero for that day rather than failing the whole calendar.
class HealthService {
  HealthService({Health? health}) : _health = health ?? Health();

  /// Remembers that we have shown the system permission sheet. On iOS this is
  /// the only signal we get — see [resolveAvailability].
  static const _connectedKey = 'health_connected_v1';

  final Health _health;
  bool _configured = false;
  bool _pluginMissing = false;

  Future<bool> _hasConnectedBefore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_connectedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _rememberConnected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_connectedKey, true);
    } catch (_) {
      // Worst case the user taps Connect again next launch.
    }
  }

  /// Decides whether the calendar can be shown.
  ///
  /// Apple deliberately never discloses whether *read* access was granted —
  /// doing so would let an app infer that a user has data they chose to hide.
  /// `hasPermissions` therefore returns null on iOS for read scopes, so the
  /// only thing we can act on is whether we have already asked. Apple's own
  /// guidance is to read regardless and render an empty result the same way
  /// as a denied one, which is what the day detail already does.
  ///
  /// Health Connect on Android does report permission state honestly, so
  /// there we use it.
  @visibleForTesting
  static HealthAvailability resolveAvailability({
    required bool isIOS,
    required bool hasConnectedBefore,
    required bool? reportedPermission,
  }) {
    if (isIOS) {
      return hasConnectedBefore
          ? HealthAvailability.ready
          : HealthAvailability.needsPermission;
    }
    return reportedPermission == true
        ? HealthAvailability.ready
        : HealthAvailability.needsPermission;
  }

  bool get isSupported => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Types we ask for, narrowed per platform because Health Connect does not
  /// split walking from cycling distance the way HealthKit does.
  List<HealthDataType> get _types {
    if (!isSupported) return const [];
    if (Platform.isIOS) {
      return const [
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_WALKING_RUNNING,
        HealthDataType.DISTANCE_CYCLING,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.EXERCISE_TIME,
        HealthDataType.WORKOUT,
      ];
    }
    return const [
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_DELTA,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WORKOUT,
    ];
  }

  /// Returns false when the plugin cannot be reached at all.
  ///
  /// Adding a plugin with native code only takes effect after a full rebuild;
  /// a hot restart leaves its method channel unregistered. That cannot resolve
  /// itself while the process lives, so the failure is remembered and logged
  /// once rather than retried on every rebuild.
  Future<bool> _ensureConfigured() async {
    if (!isSupported || _pluginMissing) return false;
    if (_configured) return true;
    try {
      await _health.configure();
      _configured = true;
      return true;
    } catch (e) {
      _pluginMissing = true;
      AppLog.health.error(
        'Plugin not registered in this build — stop the app and launch it '
        'again; a hot restart will not pick it up',
        error: e,
      );
      return false;
    }
  }

  Future<HealthAvailability> availability() async {
    if (!isSupported) return HealthAvailability.unsupported;
    if (!await _ensureConfigured()) {
      return _pluginMissing
          ? HealthAvailability.pluginMissing
          : HealthAvailability.unsupported;
    }

    if (Platform.isAndroid) {
      try {
        final status = await _health.getHealthConnectSdkStatus();
        if (status != HealthConnectSdkStatus.sdkAvailable) {
          return HealthAvailability.needsHealthConnect;
        }
      } catch (e) {
        AppLog.health.warn('Health Connect unavailable', {'error': e});
        return HealthAvailability.needsHealthConnect;
      }
    }

    final connectedBefore = await _hasConnectedBefore();

    bool? reported;
    try {
      reported = await _health.hasPermissions(_types);
    } catch (e) {
      AppLog.health.warn('Permission check failed', {'error': e});
    }

    final result = resolveAvailability(
      isIOS: Platform.isIOS,
      hasConnectedBefore: connectedBefore,
      reportedPermission: reported,
    );
    AppLog.health.debug('Availability', {
      'reported': reported,
      'connectedBefore': connectedBefore,
      'result': result.name,
    });
    return result;
  }

  /// Opens the system permission sheet. Returns true when reading is allowed.
  Future<bool> requestPermission() async {
    if (!await _ensureConfigured()) return false;
    try {
      final granted = await _health.requestAuthorization(
        _types,
        permissions: _types.map((_) => HealthDataAccess.READ).toList(),
      );
      if (granted) {
        // On iOS this only means the sheet was shown and dismissed; HealthKit
        // will not say whether the user actually allowed anything.
        await _rememberConnected();
        AppLog.health.success('Permission sheet completed');
      } else {
        AppLog.health.warn('Authorization request refused');
      }
      return granted;
    } catch (e) {
      AppLog.health.error('Authorization failed', error: e);
      return false;
    }
  }

  /// Sends the user to install or update Health Connect.
  Future<void> installHealthConnect() async {
    if (!Platform.isAndroid) return;
    if (!await _ensureConfigured()) return;
    try {
      await _health.installHealthConnect();
    } catch (e) {
      AppLog.health.error('Health Connect install failed', error: e);
    }
  }

  /// Daily totals for every day from [from] to [to], inclusive.
  ///
  /// Days with no recorded movement are omitted rather than returned empty.
  Future<Map<DateTime, DailyActivity>> fetchRange({
    required DateTime from,
    required DateTime to,
  }) async {
    if (!await _ensureConfigured()) return {};

    final start = DailyActivity.dayKey(from);
    final end = DailyActivity.dayKey(to).add(const Duration(days: 1));

    AppLog.health.info(
      'Reading ${_types.length} data types',
      {'from': start.toIso8601String().substring(0, 10),
       'to': end.toIso8601String().substring(0, 10)},
    );

    List<HealthDataPoint> points;
    try {
      points = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: start,
        endTime: end,
      );
    } catch (e) {
      AppLog.health.error('Read failed', error: e);
      return {};
    }

    points = _health.removeDuplicates(points);
    final days = _bucketByDay(points);
    AppLog.health.success(
      'Read activity',
      {'days': days.length, 'points': points.length},
    );
    return days;
  }

  Map<DateTime, DailyActivity> _bucketByDay(List<HealthDataPoint> points) {
    final days = <DateTime, DailyActivity>{};
    // On Android the only distance signal is the combined total, so cycling
    // has to be subtracted out of it using the workout records.
    final androidTotalKm = <DateTime, double>{};

    for (final point in points) {
      final key = DailyActivity.dayKey(point.dateFrom);
      final current = days[key] ?? DailyActivity(day: key);

      switch (point.type) {
        case HealthDataType.STEPS:
          days[key] = current.copyWith(
            steps: current.steps + _numeric(point).round(),
          );
        case HealthDataType.DISTANCE_WALKING_RUNNING:
          days[key] = current.copyWith(
            walkRunKm: current.walkRunKm + _metresToKm(_numeric(point)),
          );
        case HealthDataType.DISTANCE_CYCLING:
          days[key] = current.copyWith(
            cycleKm: current.cycleKm + _metresToKm(_numeric(point)),
          );
        case HealthDataType.DISTANCE_DELTA:
          androidTotalKm[key] =
              (androidTotalKm[key] ?? 0) + _metresToKm(_numeric(point));
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          days[key] = current.copyWith(
            activeKcal: current.activeKcal + _numeric(point).round(),
          );
        case HealthDataType.EXERCISE_TIME:
          days[key] = current.copyWith(
            activeMinutes: current.activeMinutes + _numeric(point).round(),
          );
        case HealthDataType.WORKOUT:
          days[key] = _addWorkout(current, point);
        default:
          break;
      }
    }

    for (final entry in androidTotalKm.entries) {
      final current = entry.value;
      final day = days[entry.key] ?? DailyActivity(day: entry.key);
      final walkRun = (current - day.cycleKm).clamp(0.0, double.infinity);
      days[entry.key] = day.copyWith(walkRunKm: walkRun);
    }

    days.removeWhere((_, value) => value.isEmpty);
    return days;
  }

  DailyActivity _addWorkout(DailyActivity day, HealthDataPoint point) {
    final value = point.value;
    if (value is! WorkoutHealthValue) return day;

    final kind = _kindOf(value.workoutActivityType);
    final km = value.totalDistance == null
        ? null
        : _metresToKm(value.totalDistance!.toDouble());
    final minutes = point.dateTo.difference(point.dateFrom).inMinutes;

    final session = ActivitySession(
      kind: kind,
      start: point.dateFrom,
      end: point.dateTo,
      km: km,
      kcal: value.totalEnergyBurned,
    );

    // Exercise minutes are a first-class type on iOS; on Android the workout
    // records are the only source, so accumulate them there.
    final minutesSoFar = Platform.isAndroid
        ? day.activeMinutes + minutes
        : day.activeMinutes;

    // Cycling distance on Android arrives only through workouts.
    final cycling = Platform.isAndroid &&
            kind == ActivityKind.cycling &&
            km != null
        ? day.cycleKm + km
        : day.cycleKm;

    return day.copyWith(
      sessions: [...day.sessions, session],
      activeMinutes: minutesSoFar,
      cycleKm: cycling,
    );
  }

  static ActivityKind _kindOf(HealthWorkoutActivityType type) {
    return switch (type) {
      HealthWorkoutActivityType.WALKING ||
      HealthWorkoutActivityType.WALKING_TREADMILL ||
      HealthWorkoutActivityType.HIKING =>
        ActivityKind.walking,
      HealthWorkoutActivityType.RUNNING ||
      HealthWorkoutActivityType.RUNNING_TREADMILL =>
        ActivityKind.running,
      HealthWorkoutActivityType.BIKING ||
      HealthWorkoutActivityType.BIKING_STATIONARY ||
      HealthWorkoutActivityType.HAND_CYCLING =>
        ActivityKind.cycling,
      _ => ActivityKind.other,
    };
  }

  static double _numeric(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) return value.numericValue.toDouble();
    return 0;
  }

  static double _metresToKm(double metres) => metres / 1000;
}
