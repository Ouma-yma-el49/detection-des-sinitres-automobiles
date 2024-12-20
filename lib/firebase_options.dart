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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDFmVfjNSgToSnXJjt1nY3aAFNpOukBO5Y',
    appId: '1:48912788665:web:d694d1d9aeae72e523ff68',
    messagingSenderId: '48912788665',
    projectId: 'loginapp-82fb2',
    authDomain: 'loginapp-82fb2.firebaseapp.com',
    storageBucket: 'loginapp-82fb2.firebasestorage.app',
    measurementId: 'G-87R2GC6N89',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3XuNfXCu08ZpmNhlH_ADFrczog2iUkFU',
    appId: '1:48912788665:android:2559551dc51b2ba023ff68',
    messagingSenderId: '48912788665',
    projectId: 'loginapp-82fb2',
    storageBucket: 'loginapp-82fb2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwDzRqfA_wa9HQbggU3HEB1gumlLhkEXA',
    appId: '1:48912788665:ios:d4f93a5e4631761023ff68',
    messagingSenderId: '48912788665',
    projectId: 'loginapp-82fb2',
    storageBucket: 'loginapp-82fb2.firebasestorage.app',
    iosBundleId: 'com.example.loginapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAwDzRqfA_wa9HQbggU3HEB1gumlLhkEXA',
    appId: '1:48912788665:ios:d4f93a5e4631761023ff68',
    messagingSenderId: '48912788665',
    projectId: 'loginapp-82fb2',
    storageBucket: 'loginapp-82fb2.firebasestorage.app',
    iosBundleId: 'com.example.loginapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDFmVfjNSgToSnXJjt1nY3aAFNpOukBO5Y',
    appId: '1:48912788665:web:fbb2fe8ea040175223ff68',
    messagingSenderId: '48912788665',
    projectId: 'loginapp-82fb2',
    authDomain: 'loginapp-82fb2.firebaseapp.com',
    storageBucket: 'loginapp-82fb2.firebasestorage.app',
    measurementId: 'G-EP55Y6K2TH',
  );
}