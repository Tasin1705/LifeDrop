import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'firebase_options.dart'; // Generated via `flutterfire configure`

// Screens
import 'splash_screen.dart';
import 'homepage/home_page.dart';
import 'dashboard/donor_dashboard.dart';
import 'hospital_dashboard.dart';
import 'auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeDrop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
      navigatorObservers: [observer], // ✅ Add this for screen tracking
      home: const SplashScreen(),
      routes: {
        '/auth': (context) => const AuthWrapper(),
        '/home': (context) => const HomePage(),
        '/dashboard': (context) => const DonorDashboard(),
        '/hospital_dashboard': (context) => const HospitalDashboard(),
      },
    );
  }
}
