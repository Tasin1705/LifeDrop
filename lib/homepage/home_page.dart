import 'package:flutter/material.dart';
import 'hero_section.dart';
import 'statistics_row.dart';
import 'why_choose_section.dart';
import 'blood_types_section.dart'; // Add this import for BloodTypesSection
import 'live_tracking_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF0F2), // Light pink background
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            LiveTrackingCard(), // Add the LiveTrackingCard here
            StatisticsRow(),
            WhyChooseSection(),
            BloodTypesSection(),
          ],
        ),
      ),
    );
  }
}
