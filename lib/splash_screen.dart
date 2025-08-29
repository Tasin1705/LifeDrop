// ignore_for_file: unused_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'homepage/home_page.dart';
import 'dashboard/donor_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;

  String username = "User";
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkLoginStatus();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(
      begin: 0.95,
      end: 1.1,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_logoController);
  }

  void _checkLoginStatus() async {
    // Add a small delay for the splash screen animation
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 191, 201),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoScale,
              child: SizedBox(
                width: 180,
                height: 180,
                child: Image.asset('assets/lifedrop.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 40),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 5),
              curve: Curves.easeInOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white12,
                color: Colors.redAccent,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
