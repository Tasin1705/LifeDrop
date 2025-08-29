import 'package:flutter/material.dart';

class LiveTrackingCard extends StatelessWidget {
  const LiveTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Live Donation Tracking",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              _buildCardItem(
                Icons.bloodtype,
                'O+ Blood Needed',
                'City Hospital - Urgent',
                '2 units',
                Colors.red[50],
                Colors.red,
              ),
              _buildCardItem(
                Icons.bloodtype,
                'AB- Blood Available',
                'Central Blood Bank',
                '5 units',
                Colors.blue[50],
                Colors.blue,
              ),
              _buildCardItem(
                Icons.calendar_today,
                'Next Donation',
                'Tomorrow, 10:00 AM',
                'Scheduled',
                Colors.green[50],
                Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem(
    IconData icon,
    String title,
    String subtitle,
    String trailing,
    Color? bgColor,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          trailing,
          style: TextStyle(color: iconColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
