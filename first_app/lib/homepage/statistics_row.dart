import 'package:flutter/material.dart';

class StatisticsRow extends StatelessWidget {
  const StatisticsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 32, // space between items horizontally
          runSpacing: 16, // space between lines when wrapped
          children: const [
            _StatCard(number: '25,000+', label: 'Lives Saved'),
            _StatCard(number: '15,000+', label: 'Active Donors'),
            _StatCard(number: '500+', label: 'Partner Hospitals'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110, // fixed width ensures consistent sizing and wrap support
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
