// ============================================================
// firebase_options.dart
// Cấu hình Firebase cho project: quan-ly-nguoi-dung-8e0b2
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  // ── Cấu hình Web ──
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyAEoRK8L_VZqAE-8gCc_-taHOGxo5tAepw',
    authDomain:        'quan-ly-nguoi-dung-8e0b2.firebaseapp.com',
    databaseURL:       'https://quan-ly-nguoi-dung-8e0b2-default-rtdb.asia-southeast1.firebasedatabase.app',
    projectId:         'quan-ly-nguoi-dung-8e0b2',
    storageBucket:     'quan-ly-nguoi-dung-8e0b2.firebasestorage.app',
    messagingSenderId: '297673531673',
    appId:             '1:297673531673:web:04931ae7ecc9fda1caa588',
  );

  // ── Cấu hình Android ──
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyAEoRK8L_VZqAE-8gCc_-taHOGxo5tAepw',
    authDomain:        'quan-ly-nguoi-dung-8e0b2.firebaseapp.com',
    databaseURL:       'https://quan-ly-nguoi-dung-8e0b2-default-rtdb.asia-southeast1.firebasedatabase.app',
    projectId:         'quan-ly-nguoi-dung-8e0b2',
    storageBucket:     'quan-ly-nguoi-dung-8e0b2.firebasestorage.app',
    messagingSenderId: '297673531673',
    appId:             '1:297673531673:web:04931ae7ecc9fda1caa588',
  );
}
