// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCyo-mwlTXFCmVMMr59l8eOn53UNLH2wjk',
    appId: '1:550284274723:web:a7f21432c8178fd8f95596',
    messagingSenderId: '550284274723',
    projectId: 'proyectotfc-fichi',
    authDomain: 'proyectotfc-fichi.firebaseapp.com',
    storageBucket: 'proyectotfc-fichi.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDcCmmf1tH3pn-FFUECnVKV2qhju_S5PKg',
    appId: '1:550284274723:android:5fd4396d630573d8f95596',
    messagingSenderId: '550284274723',
    projectId: 'proyectotfc-fichi',
    storageBucket: 'proyectotfc-fichi.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAb2dq6dwmoE0v63bIzUbgNV8McpG0ZKo',
    appId: '1:550284274723:ios:d2e4326ddc0702a7f95596',
    messagingSenderId: '550284274723',
    projectId: 'proyectotfc-fichi',
    storageBucket: 'proyectotfc-fichi.firebasestorage.app',
    iosBundleId: 'com.example.fichi',
  );
}
