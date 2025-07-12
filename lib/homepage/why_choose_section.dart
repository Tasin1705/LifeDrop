import 'package:flutter/material.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1000,
        ), // Center in wide screens
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Why Choose LifeDrop?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Our platform makes blood donation simple, safe, and impactful.\nJoin thousands of heroes making a difference every day.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Grid of features
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  FeatureCard(
                    icon: Icons.calendar_today,
                    title: 'Easy Scheduling',
                    color: Colors.red,
                    description:
                        'Book donation appointments at your convenience with our flexible scheduling system.',
                  ),
                  FeatureCard(
                    icon: Icons.location_on,
                    title: 'Location Matching',
                    color: Colors.red,
                    description:
                        'Find nearby donation centers and donors based on your location for quick response.',
                  ),
                  FeatureCard(
                    icon: Icons.security,
                    title: 'Secure & Private',
                    color: Colors.red,
                    description:
                        'Your health data is protected with enterprise-grade security and privacy measures.',
                  ),
                  FeatureCard(
                    icon: Icons.access_time,
                    title: '24/7 Emergency',
                    color: Colors.red,
                    description:
                        'Round-the-clock emergency blood request system for critical situations.',
                  ),
                  FeatureCard(
                    icon: Icons.people,
                    title: 'Community Driven',
                    color: Colors.red,
                    description:
                        'Join a community of life-savers and track your donation impact over time.',
                  ),
                  FeatureCard(
                    icon: Icons.emoji_events,
                    title: 'Recognition Program',
                    color: Colors.red,
                    description:
                        'Earn badges and recognition for your life-saving contributions to society.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
