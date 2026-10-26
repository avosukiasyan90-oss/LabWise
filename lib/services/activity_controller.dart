import 'package:flutter/foundation.dart';

import '../models/daily_activity.dart';
import 'activity_store.dart';
import 'health_service.dart';

/// Owns the activity data shared by the compact Plan card and the full
/// calendar screen, so opening one does not re-read what the other fetched.
class ActivityController extends ChangeNotifier {
  ActivityController({required this.healthService, required this.store});

  final HealthService healthService;
  final ActivityStore store;

  Map<DateTime, DailyActivity> _days = {};
  HealthAvailability _availability = HealthAvailability.unsupported;
  bool _loading = true;
  bool _connecting = false;
  bool _booted = false;

  Map<DateTime, DailyActivity> get days => _days;
  HealthAvailability get availability => _availability;
  bool get loading => _loading;
  bool get connecting => _connecting;
  bool get isReady => _availability == HealthAvailability.ready;

  DailyActivity? forDay(DateTime day) => _days[DailyActivity.dayKey(day)];

  DailyActivity? get today => forDay(DateTime.now());

  /// The last [count] days ending today, oldest first. Entries are null where
  /// nothing was recorded, so callers can render a gap rather than a zero.
  List<MapEntry<DateTime, DailyActivity?>> recentDays(int count) {
    final end = DailyActivity.dayKey(DateTime.now());
    return List.generate(count, (i) {
      final day = end.subtract(Duration(days: count - 1 - i));
      return MapEntry(day, forDay(day));
    });
  }

  /// Runs once per app session; later calls are no-ops.
  Future<void> ensureLoaded() async {
    if (_booted) return;
    _booted = true;

    _days = store.load();
    notifyListeners();

    _availability = await healthService.availability();
    if (isReady) await loadMonth(DateTime.now());

    _loading = false;
    notifyListeners();
  }

  Future<void> loadMonth(DateTime month) async {
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0);

    final fresh = await healthService.fetchRange(from: from, to: to);
    _days = await store.merge(fresh);
    notifyListeners();
  }

  /// Opens the system permission sheet, or sends the user to install Health
  /// Connect when that is what is missing.
  Future<void> connect() async {
    _connecting = true;
    notifyListeners();

    if (_availability == HealthAvailability.needsHealthConnect) {
      await healthService.installHealthConnect();
    } else {
      await healthService.requestPermission();
    }

    _availability = await healthService.availability();
    _connecting = false;
    notifyListeners();

    if (isReady) await loadMonth(DateTime.now());
  }
}
