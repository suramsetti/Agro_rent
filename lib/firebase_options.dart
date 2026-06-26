// File generated manually - Firebase configuration for all platforms
// To get complete web configuration, go to Firebase Console > Project Settings > Your apps > Web app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBe4_10qnRbTo0m_mYAH-kO70jHTPc85Kw',
    appId: '1:187417583888:web:79d6c95c50fc2aa1160595',
    messagingSenderId: '187417583888',
    projectId: 'agrorent-ccd79',
    authDomain: 'agrorent-ccd79.firebaseapp.com',
    storageBucket: 'agrorent-ccd79.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBe4_10qnRbTo0m_mYAH-kO70jHTPc85Kw',
    appId: '1:187417583888:android:0681bad69c710870160595',
    messagingSenderId: '187417583888',
    projectId: 'agrorent-ccd79',
    storageBucket: 'agrorent-ccd79.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBe4_10qnRbTo0m_mYAH-kO70jHTPc85Kw',
    appId: '1:187417583888:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '187417583888',
    projectId: 'agrorent-ccd79',
    storageBucket: 'agrorent-ccd79.firebasestorage.app',
    iosBundleId: 'com.example.fPro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBe4_10qnRbTo0m_mYAH-kO70jHTPc85Kw',
    appId: '1:187417583888:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: '187417583888',
    projectId: 'agrorent-ccd79',
    storageBucket: 'agrorent-ccd79.firebasestorage.app',
    iosBundleId: 'com.example.fPro',
  );
}

