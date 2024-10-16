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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCt0Zg7xOA9IbM7lBfolGT8fXZkvaK0lAs',
    appId: '1:861174693153:web:4d55e223956d0cb2f09260',
    messagingSenderId: '861174693153',
    projectId: 'chatapp-c830a',
    authDomain: 'chatapp-c830a.firebaseapp.com',
    storageBucket: 'chatapp-c830a.appspot.com',
    measurementId: 'G-7VDJZV1S1T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANn888e5iD5Q7mWd8m-tn8fufuLV2V1YU',
    appId: '1:861174693153:android:d5a3ac2223d9cbeaf09260',
    messagingSenderId: '861174693153',
    projectId: 'chatapp-c830a',
    storageBucket: 'chatapp-c830a.appspot.com',
  );
}
