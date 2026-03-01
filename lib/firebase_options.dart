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

  // TODO: Replace these with your actual Firebase configuration values
  // via `flutterfire configure`. These are dummy placeholders to allow compilation.

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCTiT_dlQflM4qBfduKQavYLT6vgv53mZo',
    appId: '1:222822058756:web:6f84e1c04062c244b65e51',
    messagingSenderId: '222822058756',
    projectId: 'wheelo-2b453',
    authDomain: 'wheelo-2b453.firebaseapp.com',
    storageBucket: 'wheelo-2b453.firebasestorage.app',
    measurementId: 'G-9PBM0T8WNG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmY4jyp0ZpZqPMq33hpa8_bNoqMxAJt34',
    appId: '1:222822058756:android:15939ed49e64c75cb65e51',
    messagingSenderId: '222822058756',
    projectId: 'wheelo-2b453',
    storageBucket: 'wheelo-2b453.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8o8dGsqKWfABTKBV7SMqcX9-Tyj-OeVc',
    appId: '1:222822058756:ios:d98a6378d024e9b1b65e51',
    messagingSenderId: '222822058756',
    projectId: 'wheelo-2b453',
    storageBucket: 'wheelo-2b453.firebasestorage.app',
    iosClientId: '222822058756-0oqec2rn5gqi6dfl3630rih4uv5jgfsm.apps.googleusercontent.com',
    iosBundleId: 'com.example.wheelo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD8o8dGsqKWfABTKBV7SMqcX9-Tyj-OeVc',
    appId: '1:222822058756:ios:d98a6378d024e9b1b65e51',
    messagingSenderId: '222822058756',
    projectId: 'wheelo-2b453',
    storageBucket: 'wheelo-2b453.firebasestorage.app',
    iosClientId: '222822058756-0oqec2rn5gqi6dfl3630rih4uv5jgfsm.apps.googleusercontent.com',
    iosBundleId: 'com.example.wheelo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCTiT_dlQflM4qBfduKQavYLT6vgv53mZo',
    appId: '1:222822058756:web:6f84e1c04062c244b65e51',
    messagingSenderId: '222822058756',
    projectId: 'wheelo-2b453',
    authDomain: 'wheelo-2b453.firebaseapp.com',
    storageBucket: 'wheelo-2b453.firebasestorage.app',
    measurementId: 'G-9PBM0T8WNG',
  );

}