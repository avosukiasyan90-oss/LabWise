import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/services/health_service.dart';

void main() {
  // Apple never reports whether read access was granted, so the only thing
  // the app can act on is whether it has already shown the sheet.
  group('iOS', () {
    test('asks to connect before the sheet has ever been shown', () {
      expect(
        HealthService.resolveAvailability(
          isIOS: true,
          hasConnectedBefore: false,
          reportedPermission: null,
        ),
        HealthAvailability.needsPermission,
      );
    });

    test('shows the calendar once the sheet has been completed', () {
      expect(
        HealthService.resolveAvailability(
          isIOS: true,
          hasConnectedBefore: true,
          reportedPermission: null,
        ),
        HealthAvailability.ready,
      );
    });

    test('ignores the undetermined permission answer entirely', () {
      // This is the bug that kept the connect prompt on screen forever:
      // HealthKit returns null for read scopes, which is not "denied".
      for (final reported in <bool?>[null, false]) {
        expect(
          HealthService.resolveAvailability(
            isIOS: true,
            hasConnectedBefore: true,
            reportedPermission: reported,
          ),
          HealthAvailability.ready,
          reason: 'reportedPermission=$reported should not block the calendar',
        );
      }
    });
  });

  // Health Connect does answer honestly, so Android trusts it.
  group('Android', () {
    test('shows the calendar when permission is reported granted', () {
      expect(
        HealthService.resolveAvailability(
          isIOS: false,
          hasConnectedBefore: false,
          reportedPermission: true,
        ),
        HealthAvailability.ready,
      );
    });

    test('asks to connect when permission is reported denied', () {
      expect(
        HealthService.resolveAvailability(
          isIOS: false,
          hasConnectedBefore: true,
          reportedPermission: false,
        ),
        HealthAvailability.needsPermission,
      );
    });

    test('asks to connect when permission is undetermined', () {
      expect(
        HealthService.resolveAvailability(
          isIOS: false,
          hasConnectedBefore: true,
          reportedPermission: null,
        ),
        HealthAvailability.needsPermission,
      );
    });
  });
}
