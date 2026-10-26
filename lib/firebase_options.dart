// Firebase options for LabWise.
// Generate real values with:
//   ./tool/setup_firebase.sh
// or:
//   dart pub global run flutterfire_cli:flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static bool get isConfigured {
    try {
      final key = currentPlatform.apiKey;
      return key.isNotEmpty && key != 'YOUR_API_KEY';
    } catch (_) {
      return false;
    }
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCttsmN6DbCic2iSzozS-4rmqg9DIQhRiw',
    appId: '1:414398000383:web:9f79ee134380d16f5cf0ca',
    messagingSenderId: '414398000383',
    projectId: 'labwise-e7923',
    authDomain: 'labwise-e7923.firebaseapp.com',
    storageBucket: 'labwise-e7923.firebasestorage.app',
    measurementId: 'G-B6ZKMD93FD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAr4hbrluKFartUso5aG6iLWAunL6dbFy8',
    appId: '1:414398000383:android:108a5d3eab005ca55cf0ca',
    messagingSenderId: '414398000383',
    projectId: 'labwise-e7923',
    storageBucket: 'labwise-e7923.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlOc_zEpHP92vYjoEtZTPORHkv7-oxvLc',
    appId: '1:414398000383:ios:c9e23eb3f14555de5cf0ca',
    messagingSenderId: '414398000383',
    projectId: 'labwise-e7923',
    storageBucket: 'labwise-e7923.firebasestorage.app',
    iosClientId: '414398000383-38tmu94r0di7rang5j2mce0pil61bnq1.apps.googleusercontent.com',
    iosBundleId: 'com.healthy.healthyProject',
  );
}
