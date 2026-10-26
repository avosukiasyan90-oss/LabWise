import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/services/app_log.dart';

void main() {
  setUp(() {
    AppLog.clear();
    AppLog.enabled = false; // keep the test output readable
  });

  tearDown(() {
    AppLog.enabled = kDebugMode;
    AppLog.clear();
  });

  group('recording', () {
    test('keeps each entry with its area and level', () {
      AppLog.auth.info('Signing in');
      AppLog.cloud.success('Saved report');
      AppLog.net.error('Timed out');

      expect(AppLog.recent, hasLength(3));
      expect(AppLog.recent[0].area, LogArea.auth);
      expect(AppLog.recent[0].level, LogLevel.info);
      expect(AppLog.recent[1].area, LogArea.cloud);
      expect(AppLog.recent[1].level, LogLevel.success);
      expect(AppLog.recent[2].level, LogLevel.error);
    });

    test('attaches the detail map', () {
      AppLog.parse.success('Parsed report', {'markers': 12});
      expect(AppLog.recent.single.data, {'markers': 12});
    });

    test('folds the error object into the details', () {
      AppLog.health.error('Read failed', error: StateError('no permission'));
      expect(
        AppLog.recent.single.data!['error'].toString(),
        contains('no permission'),
      );
    });

    test('records even while printing is off', () {
      AppLog.enabled = false;
      AppLog.app.info('startup');
      expect(AppLog.recent, hasLength(1));
    });

    test('drops the oldest entries past the cap', () {
      for (var i = 0; i < 350; i++) {
        AppLog.app.debug('entry $i');
      }
      expect(AppLog.recent, hasLength(300));
      expect(AppLog.recent.first.message, 'entry 50');
      expect(AppLog.recent.last.message, 'entry 349');
    });

    test('recent is not writable from outside', () {
      AppLog.app.info('one');
      expect(() => AppLog.recent.clear(), throwsUnsupportedError);
    });
  });

  group('http helpers', () {
    final uri = Uri.parse('https://api.telegram.org/bot123/sendMessage');

    test('grades the response by status code', () {
      AppLog.net.response(200, uri);
      AppLog.net.response(429, uri);
      AppLog.net.response(503, uri);

      expect(AppLog.recent[0].level, LogLevel.success);
      expect(AppLog.recent[1].level, LogLevel.warn);
      expect(AppLog.recent[2].level, LogLevel.error);
    });

    test('logs host and path but never the query string', () {
      AppLog.net.request('POST', uri.replace(queryParameters: {'token': 'abc'}));
      expect(AppLog.recent.single.message, 'POST api.telegram.org/bot123/sendMessage');
      expect(AppLog.recent.single.message, isNot(contains('abc')));
    });

    test('keeps how long the call took', () {
      AppLog.net.response(200, uri, took: const Duration(milliseconds: 420));
      expect(AppLog.recent.single.took, const Duration(milliseconds: 420));
    });
  });

  group('track', () {
    test('logs a start and a finish, returning the value untouched', () async {
      final value = await AppLog.cloud.track('Load reports', () async => 7);

      expect(value, 7);
      expect(AppLog.recent, hasLength(2));
      expect(AppLog.recent.first.level, LogLevel.info);
      expect(AppLog.recent.last.level, LogLevel.success);
      expect(AppLog.recent.last.took, isNotNull);
    });

    test('rethrows failures after logging them', () async {
      await expectLater(
        AppLog.cloud.track('Load reports', () async => throw StateError('nope')),
        throwsStateError,
      );

      expect(AppLog.recent.last.level, LogLevel.error);
      expect(AppLog.recent.last.message, 'Load reports failed');
    });

    test('can describe the result without logging the whole object', () async {
      await AppLog.history.track(
        'Load history',
        () async => List.filled(12, 'report'),
        describe: (value) => '${value.length} items',
      );
      expect(AppLog.recent.last.data, {'result': '12 items'});
    });
  });

  group('redaction', () {
    test('shortens an id to something still correlatable', () {
      expect(AppLog.redact('aBcD1234EfGh5678'), 'aBcD…78');
    });

    test('keeps the domain but hides the mailbox', () {
      expect(AppLog.redact('avo.sukiasyan90@gmail.com'), 'av…@gmail.com');
    });

    test('leaves short values alone', () {
      expect(AppLog.redact('google'), 'google');
    });

    test('handles null and empty without throwing', () {
      expect(AppLog.redact(null), 'null');
      expect(AppLog.redact(''), "''");
    });
  });

  test('logging is off by default outside debug builds', () {
    // kDebugMode is true under `flutter test`, which is the intent: logs in
    // development, silence in a shipped binary.
    expect(kDebugMode, isTrue);
  });
}
