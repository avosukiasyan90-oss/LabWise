import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_log.dart';

/// Device and build details attached to a signup notice.
class DeviceContext {
  const DeviceContext({
    this.platform,
    this.osVersion,
    this.deviceModel,
    this.appVersion,
    this.locale,
    this.timeZone,
  });

  final String? platform;
  final String? osVersion;
  final String? deviceModel;
  final String? appVersion;
  final String? locale;
  final String? timeZone;

  /// Reads what the platform will tell us. Every lookup is independently
  /// guarded: a signup notice is never worth failing a sign-in over.
  static Future<DeviceContext> collect() async {
    String? appVersion;
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version} (${info.buildNumber})';
    } catch (e) {
      AppLog.app.debug('Package info unavailable', {'error': e});
    }

    String? model;
    String? osVersion;
    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final ios = await plugin.iosInfo;
        model = ios.utsname.machine;
        osVersion = '${ios.systemName} ${ios.systemVersion}';
      } else if (Platform.isAndroid) {
        final android = await plugin.androidInfo;
        model = '${android.manufacturer} ${android.model}';
        osVersion = 'Android ${android.version.release}'
            ' (API ${android.version.sdkInt})';
      }
    } catch (e) {
      AppLog.app.debug('Device info unavailable', {'error': e});
    }

    return DeviceContext(
      platform: _platformName(),
      osVersion: osVersion ?? _fallbackOsVersion(),
      deviceModel: model,
      appVersion: appVersion,
      locale: _locale(),
      timeZone: _timeZone(),
    );
  }

  static String? _platformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return null;
  }

  static String? _fallbackOsVersion() {
    if (kIsWeb) return null;
    try {
      return Platform.operatingSystemVersion;
    } catch (_) {
      return null;
    }
  }

  static String? _locale() {
    try {
      return PlatformDispatcher.instance.locale.toLanguageTag();
    } catch (_) {
      return null;
    }
  }

  static String? _timeZone() {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '${DateTime.now().timeZoneName} (UTC$sign$hours:$minutes)';
  }
}
