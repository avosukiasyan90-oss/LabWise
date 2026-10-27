import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_project/models/medication.dart';
import 'package:healthy_project/services/notification_service.dart';

void main() {
  group('reminder payloads', () {
    test('round-trip identifies the exact dose', () {
      const id = 'f1f0c4a2-1111-2222-3333-444455556666';
      final at = DateTime(2026, 10, 28, 8, 30);

      final decoded =
          NotificationService.decodePayload(
        NotificationService.encodePayload(id, at),
      );

      expect(decoded, isNotNull);
      expect(decoded!.medicationId, id);
      expect(decoded.at, at);
    });

    test('the decoded time matches the dose key the model uses', () {
      final at = DateTime(2026, 10, 28, 21, 5);
      final decoded = NotificationService.decodePayload(
        NotificationService.encodePayload('abc', at),
      );
      expect(Medication.doseKey(decoded!.at), Medication.doseKey(at));
    });

    test('two doses of the same medicine decode separately', () {
      const id = 'abc';
      final morning = DateTime(2026, 10, 28, 8, 0);
      final evening = DateTime(2026, 10, 28, 20, 0);

      final a = NotificationService.decodePayload(
        NotificationService.encodePayload(id, morning),
      );
      final b = NotificationService.decodePayload(
        NotificationService.encodePayload(id, evening),
      );

      expect(a!.at, isNot(b!.at));
      expect(a.medicationId, b.medicationId);
    });

    test('ignores payloads that are not doses', () {
      for (final junk in [null, '', 'hello', '|', 'abc|', '|2026-10-28']) {
        expect(
          NotificationService.decodePayload(junk),
          isNull,
          reason: 'should ignore ${junk ?? 'null'}',
        );
      }
    });

    test('survives an id containing the separator', () {
      // Splitting on the last separator keeps odd ids intact.
      const id = 'weird|id';
      final at = DateTime(2026, 10, 28, 9, 0);
      final decoded = NotificationService.decodePayload(
        NotificationService.encodePayload(id, at),
      );

      expect(decoded!.medicationId, id);
      expect(decoded.at, at);
    });
  });

  test('tapping a reminder marks that dose and no other', () {
    final medication = Medication(
      id: 'abc',
      title: 'Vitamin D',
      startDate: DateTime(2026, 10, 1),
      times: const [
        DoseTime(hour: 8, minute: 0),
        DoseTime(hour: 20, minute: 0),
      ],
    );

    final tapped = DateTime(2026, 10, 28, 8, 0);
    final decoded = NotificationService.decodePayload(
      NotificationService.encodePayload(medication.id, tapped),
    )!;

    final updated = medication.markTaken(decoded.at, taken: true);

    expect(updated.isTakenAt(tapped), isTrue);
    expect(updated.isTakenAt(DateTime(2026, 10, 28, 20, 0)), isFalse);
  });
}
