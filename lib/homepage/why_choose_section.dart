import 'package:flutter/material.dart';
import 'dart:async';

class WhyChooseSection extends StatefulWidget {
  const WhyChooseSection({super.key});

  @override
  State<WhyChooseSection> createState() => _WhyChooseSectionState();
}

class _WhyChooseSectionState extends State<WhyChooseSection> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  final List<Widget> _features = [];

  @override
  void initState() {
    super.initState();

    _features.addAll([
      const FeatureCard(
        icon: Icons.calendar_today,
        title: 'Easy Scheduling',
        color: Colors.red,
        description:
            'Book donation appointments at your convenience with our flexible scheduling system.',
      ),
      const FeatureCard(
        icon: Icons.location_on,
        title: 'Location Matching',
        color: Colors.red,
        description:
            'Find nearby donation centers and donors based on your location for quick response.',
      ),
      const FeatureCard(
        icon: Icons.security,
        title: 'Secure & Private',
        color: Colors.red,
        description:
            'Your health data is protected with enterprise-grade security and privacy measures.',
      ),
      const FeatureCard(
        icon: Icons.access_time,
        title: '24/7 Emergency',
        color: Colors.red,
        description:
            'Round-the-clock emergency blood request system for critical situations.',
      ),
      const FeatureCard(
        icon: Icons.people,
        title: 'Community Driven',
        color: Colors.red,
        description:
            'Join a community of life-savers and track your donation impact over time.',
      ),
      const FeatureCard(
        icon: Icons.emoji_events,
        title: 'Recognition Program',
        color: Colors.red,
        description:
            'Earn badges and recognition for your life-saving contributions to society.',
      ),
    ]);

    // Start from a reasonable middle index for infinite scrolling
    _currentPage = 50;
    _pageController = PageController(
      viewportFraction: 0.92,
      initialPage: _currentPage,
    );

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients || !mounted) return;
      
      // Reset to middle range if we get too high to prevent overflow
      if (_currentPage > 10000) {
        _currentPage = 50;
        _pageController.jumpToPage(_currentPage);
      }
      
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
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
              const SizedBox(height: 20),

              // Infinite carousel
              SizedBox(
                height: 190,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth * 0.90;
                    return PageView.builder(
                      controller: _pageController,
                      padEnds: false,
                      itemCount: null, // Infinite items
                      itemBuilder: (context, index) {
                        // Map index back to real feature with safety check
                        final featureIndex = index % _features.length;
                        if (featureIndex >= _features.length) return Container();
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Center(
                            child: SizedBox(
                              width: cardWidth,
                              height: 170,
                              child: _features[featureIndex],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
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
    return Card(
      elevation: 5,
      color: const Color.fromARGB(255, 223, 216, 218),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        height: 170,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(5),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 6),
            
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Description - increased space and smaller font
            Expanded(
              child: Center(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
