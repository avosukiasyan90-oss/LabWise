import 'package:flutter/foundation.dart';

/// Which part of the app an entry came from.
enum LogArea {
  app('APP', '🚀'),
  auth('AUTH', '🔐'),
  net('HTTP', '🌐'),
  cloud('CLOUD', '☁️'),
  storage('STORAGE', '📦'),
  health('HEALTH', '🏃'),
  parse('PARSE', '📄'),
  ai('AI', '🤖'),
  profile('PROFILE', '👤'),
  history('HISTORY', '🗂️'),
  cache('CACHE', '💾'),
  ui('UI', '🎨');

  const LogArea(this.label, this.icon);
  final String label;
  final String icon;
}

/// How much attention an entry deserves.
enum LogLevel {
  debug('🔍'),
  info('▶️'),
  success('✅'),
  warn('⚠️'),
  error('⛔');

  const LogLevel(this.icon);
  final String icon;
}

/// One line in the log panel, kept so an in-app viewer can replay them.
class LogEntry {
  LogEntry({
    required this.at,
    required this.area,
    required this.level,
    required this.message,
    this.data,
    this.took,
  });

  final DateTime at;
  final LogArea area;
  final LogLevel level;
  final String message;
  final Map<String, Object?>? data;
  final Duration? took;
}

/// Readable, icon-tagged logging for every request and action.
///
/// Logging is off in release builds. This app handles medical records, so
/// anything printed here must never reach a shipped binary — and values that
/// could identify someone are shortened by [redact] even in debug.
class AppLog {
  AppLog._();

  /// Debug builds only. Flip deliberately if you need logs from a profile run.
  static bool enabled = kDebugMode;

  /// Longest area label, so the columns line up.
  static final int _pad =
      LogArea.values.map((a) => a.label.length).reduce((a, b) => a > b ? a : b);

  static const int _maxRecent = 300;
  static final List<LogEntry> _recent = [];

  /// Most recent entries, oldest first.
  static List<LogEntry> get recent => List.unmodifiable(_recent);

  static void clear() => _recent.clear();

  static const app = LogChannel(LogArea.app);
  static const auth = LogChannel(LogArea.auth);
  static const net = LogChannel(LogArea.net);
  static const cloud = LogChannel(LogArea.cloud);
  static const storage = LogChannel(LogArea.storage);
  static const health = LogChannel(LogArea.health);
  static const parse = LogChannel(LogArea.parse);
  static const ai = LogChannel(LogArea.ai);
  static const profile = LogChannel(LogArea.profile);
  static const history = LogChannel(LogArea.history);
  static const cache = LogChannel(LogArea.cache);
  static const ui = LogChannel(LogArea.ui);

  /// Shortens anything that could identify a person: ids, emails, tokens.
  ///
  /// Keeps enough to correlate two lines without printing the whole value.
  static String redact(Object? value) {
    final text = value?.toString() ?? 'null';
    if (text.isEmpty) return "''";

    if (text.contains('@')) {
      final at = text.indexOf('@');
      final name = text.substring(0, at);
      final domain = text.substring(at);
      final head = name.length <= 2 ? name : name.substring(0, 2);
      return '$head…$domain';
    }

    if (text.length <= 8) return text;
    return '${text.substring(0, 4)}…${text.substring(text.length - 2)}';
  }

  static void _write(LogEntry entry) {
    _recent.add(entry);
    if (_recent.length > _maxRecent) _recent.removeAt(0);
    if (!enabled) return;

    final time = _clock(entry.at);
    final area = entry.area.label.padRight(_pad);
    final buffer = StringBuffer(
      '$time ${entry.area.icon} $area ${entry.level.icon} ${entry.message}',
    );

    if (entry.took != null) buffer.write(' · ${_duration(entry.took!)}');

    final data = entry.data;
    if (data != null && data.isNotEmpty) {
      final pairs =
          data.entries.map((e) => '${e.key}=${e.value}').join(', ');
      buffer.write(' · $pairs');
    }

    debugPrint(buffer.toString());
  }

  static String _clock(DateTime at) {
    String two(int v) => v.toString().padLeft(2, '0');
    final ms = at.millisecond.toString().padLeft(3, '0');
    return '${two(at.hour)}:${two(at.minute)}:${two(at.second)}.$ms';
  }

  static String _duration(Duration took) {
    if (took.inMilliseconds < 1000) return '${took.inMilliseconds}ms';
    return '${(took.inMilliseconds / 1000).toStringAsFixed(2)}s';
  }
}

/// A logger bound to one area of the app.
class LogChannel {
  const LogChannel(this.area);

  final LogArea area;

  void debug(String message, [Map<String, Object?>? data]) =>
      _log(LogLevel.debug, message, data);

  void info(String message, [Map<String, Object?>? data]) =>
      _log(LogLevel.info, message, data);

  void success(String message, [Map<String, Object?>? data]) =>
      _log(LogLevel.success, message, data);

  void warn(String message, [Map<String, Object?>? data]) =>
      _log(LogLevel.warn, message, data);

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    final payload = <String, Object?>{...?data};
    if (error != null) payload['error'] = error.toString();
    _log(LogLevel.error, message, payload);
    if (AppLog.enabled && stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  /// An outbound call about to be made.
  void request(String method, Uri uri, [Map<String, Object?>? data]) =>
      _log(LogLevel.info, '$method ${uri.host}${uri.path}', data);

  /// The reply to an outbound call, graded by status code.
  void response(
    int status,
    Uri uri, {
    Duration? took,
    int? bytes,
  }) {
    final level = status >= 500
        ? LogLevel.error
        : status >= 400
            ? LogLevel.warn
            : LogLevel.success;
    AppLog._write(
      LogEntry(
        at: DateTime.now(),
        area: area,
        level: level,
        message: '$status ${uri.host}${uri.path}',
        took: took,
        data: bytes == null ? null : {'bytes': bytes},
      ),
    );
  }

  /// Runs [body], logging when it starts, how long it took, and how it ended.
  ///
  /// The result is returned untouched and failures are rethrown, so wrapping
  /// a call in this never changes its behaviour.
  Future<T> track<T>(
    String action,
    Future<T> Function() body, {
    Map<String, Object?>? data,
    String Function(T value)? describe,
  }) async {
    final started = DateTime.now();
    info('$action…', data);
    try {
      final result = await body();
      AppLog._write(
        LogEntry(
          at: DateTime.now(),
          area: area,
          level: LogLevel.success,
          message: action,
          took: DateTime.now().difference(started),
          data: describe == null ? null : {'result': describe(result)},
        ),
      );
      return result;
    } catch (e) {
      AppLog._write(
        LogEntry(
          at: DateTime.now(),
          area: area,
          level: LogLevel.error,
          message: '$action failed',
          took: DateTime.now().difference(started),
          data: {'error': e},
        ),
      );
      rethrow;
    }
  }

  void _log(LogLevel level, String message, Map<String, Object?>? data) {
    AppLog._write(
      LogEntry(
        at: DateTime.now(),
        area: area,
        level: level,
        message: message,
        data: data,
      ),
    );
  }
}
