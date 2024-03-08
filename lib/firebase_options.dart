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
    apiKey: 'AIzaSyDHeg44LEoVmRUq5pFkZpHDEI-SYLixVV4',
    appId: '1:425749184090:web:959c5ad64b5bd77562e263',
    messagingSenderId: '425749184090',
    projectId: 'flowerwisdom-4b40c',
    authDomain: 'flowerwisdom-4b40c.firebaseapp.com',
    storageBucket: 'flowerwisdom-4b40c.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDKK4L91MFktD5-rm-CEIkqtBVbx0vvU04',
    appId: '1:425749184090:android:118166541828b97d62e263',
    messagingSenderId: '425749184090',
    projectId: 'flowerwisdom-4b40c',
    storageBucket: 'flowerwisdom-4b40c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAiT_eCHYyk9TW-XlBddVQUlF4u9iWwElQ',
    appId: '1:425749184090:ios:088b25e9f242214262e263',
    messagingSenderId: '425749184090',
    projectId: 'flowerwisdom-4b40c',
    storageBucket: 'flowerwisdom-4b40c.appspot.com',
    iosBundleId: 'com.example.flowerwisdom',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAiT_eCHYyk9TW-XlBddVQUlF4u9iWwElQ',
    appId: '1:425749184090:ios:3979517cfbc150f062e263',
    messagingSenderId: '425749184090',
    projectId: 'flowerwisdom-4b40c',
    storageBucket: 'flowerwisdom-4b40c.appspot.com',
    iosBundleId: 'com.example.flowerwisdom.RunnerTests',
  );
}
