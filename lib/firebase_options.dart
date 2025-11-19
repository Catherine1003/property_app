import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported on this platform.',
        );
    }
  }




  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAkCnVVqBQQ00KekwpWZPzoOgSoONV2es4",
    appId: "1:633794127574:android:828ab05efc0b24971f4b77",
    messagingSenderId: "633794127574",
    projectId: "property-listing-b9b39",
    storageBucket: "property-listing-b9b39.firebasestorage.app",
  );




  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDTgV1lQNIB-GOn8hBJlFPBxK6Cl4JTl1Q",
    appId: "1:633794127574:ios:b715df46650da8071f4b77",
    messagingSenderId: "633794127574",
    projectId: "property-listing-b9b39",
    storageBucket: "property-listing-b9b39.firebasestorage.app",
    iosBundleId: "com.example.propertyApp",
  );
}