import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthy_project/main.dart';
import 'package:healthy_project/services/auth_service.dart';
import 'package:healthy_project/services/cloud_history_service.dart';
import 'package:healthy_project/services/activity_store.dart';
import 'package:healthy_project/services/history_store.dart';
import 'package:healthy_project/services/locale_controller.dart';
import 'package:healthy_project/services/profile_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LabWise shows Firebase setup when not configured', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await HistoryStore.create();

    await tester.pumpWidget(
      LabWiseApp(
        authService: AuthService(),
        localStore: store,
        cloudHistory: CloudHistoryService(local: store),
        profileService: ProfileService(),
        localeController: await LocaleController.load(),
        activityStore: await ActivityStore.create(),
        firebaseReady: false,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('LabWise Health'), findsOneWidget);
    expect(find.textContaining('Firebase is not configured'), findsOneWidget);
    expect(find.textContaining('setup_firebase.sh'), findsOneWidget);
  });
}
