import 'package:first_app/hospital_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:first_app/homepage/home_page.dart';
import 'package:first_app/dashboard/donor_dashboard.dart';


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
        '/': (context) => const HomePage(),
        '/dashboard': (context) => const DonorDashboard(),
        '/hospital-dashboard': (context) => const HospitalDashboard(),
      },
    );
  }
}
