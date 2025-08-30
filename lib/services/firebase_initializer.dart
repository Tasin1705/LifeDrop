import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// We'll generate this file using the Firebase CLI
// import '../firebase_options.dart';

class FirebaseInitializer {
  /// Initialize Firebase services
  static Future<void> initialize() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // If we have firebase_options.dart, use it
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );

      // If we don't have firebase_options.dart yet, use this
      await Firebase.initializeApp();

      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  /// Check if Firebase is properly connected
  static Future<bool> checkConnection() async {
    try {
      // This will throw an exception if not properly initialized
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }
}
