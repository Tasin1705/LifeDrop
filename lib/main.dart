import 'package:flutter/material.dart';
import 'package:first_app/homepage/home_page.dart';
import 'package:first_app/dashboard/donor_dashboard.dart';
import 'package:first_app/splash_screen.dart';
import 'package:first_app/homepage/login_transition_splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeDrop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/dashboard': (context) => const DonorDashboard(),
        '/transitionSplash': (context) => const LoginTransitionSplash(),
      },
    );
  }
}
