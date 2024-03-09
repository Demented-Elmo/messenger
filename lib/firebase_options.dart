// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyBUXfZXJS73_-IlARBemU-Swy1p-E2lYSs',
    appId: '1:373948894454:web:edea8c6ac1d79b4ab4f0d7',
    messagingSenderId: '373948894454',
    projectId: 'de-messenger',
    authDomain: 'de-messenger.firebaseapp.com',
    databaseURL: 'https://de-messenger-default-rtdb.firebaseio.com',
    storageBucket: 'de-messenger.appspot.com',
    measurementId: 'G-ZJFR16YR6M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkPHjQK2bBLqW2J0NR5vU7k2jfpSXCNBU',
    appId: '1:373948894454:android:f04663fcc750c009b4f0d7',
    messagingSenderId: '373948894454',
    projectId: 'de-messenger',
    databaseURL: 'https://de-messenger-default-rtdb.firebaseio.com',
    storageBucket: 'de-messenger.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAeggfpY0PTumQtDlWgF2JVcje2AgX25vU',
    appId: '1:373948894454:ios:121e7c9deeb670cab4f0d7',
    messagingSenderId: '373948894454',
    projectId: 'de-messenger',
    databaseURL: 'https://de-messenger-default-rtdb.firebaseio.com',
    storageBucket: 'de-messenger.appspot.com',
    iosBundleId: 'com.messenger.dementedelmo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAeggfpY0PTumQtDlWgF2JVcje2AgX25vU',
    appId: '1:373948894454:ios:067a43018238111fb4f0d7',
    messagingSenderId: '373948894454',
    projectId: 'de-messenger',
    databaseURL: 'https://de-messenger-default-rtdb.firebaseio.com',
    storageBucket: 'de-messenger.appspot.com',
    iosBundleId: 'com.example.messenger',
  );
}
