import 'package:flutter/material.dart';

class DonationSummaryScreen extends StatelessWidget {
  const DonationSummaryScreen({super.key});

  // 🧩 Reusable Card Builder
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon inside circle
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            // Title and Value Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 🧱 Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Donation Summary'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Your Donation Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 32),
            _buildStatCard(
              icon: Icons.water_drop,
              title: 'Total Donations',
              value: '3',
              color: Colors.redAccent,
            ),
            _buildStatCard(
              icon: Icons.date_range,
              title: 'Last Donation Date',
              value: '2023-11-25',
              color: Colors.deepOrange,
            ),
            _buildStatCard(
              icon: Icons.bloodtype,
              title: 'Last Donation Type',
              value: 'Whole Blood',
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}
