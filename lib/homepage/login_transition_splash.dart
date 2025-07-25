import 'dart:async';
import 'package:flutter/material.dart';
import 'package:first_app/dashboard/donor_dashboard.dart';

class LoginTransitionSplash extends StatefulWidget {
  const LoginTransitionSplash({super.key});

  @override
  State<LoginTransitionSplash> createState() => _LoginTransitionSplashState();
}

class _LoginTransitionSplashState extends State<LoginTransitionSplash>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DonorDashboard()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 191, 201),
      body: Center(
        child: ScaleTransition(
          scale: _logoScale,
          child: SizedBox(
            width: 180,
            height: 180,
            child: Image.asset('assets/lifedrop.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
