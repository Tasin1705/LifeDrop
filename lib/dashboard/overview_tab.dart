import 'package:flutter/material.dart';
import 'package:first_app/blood_request/blood_request_form.dart';


class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Welcome back Savior !\nThank you for being a life-saver. Your donations make a real difference.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: const [
            Expanded(
              child: DashboardCard(
                icon: Icons.favorite,
                value: '3',
                label: 'Total Donations',
                color: Color(0xFFFFCDD2),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                icon: Icons.bloodtype,
                value: 'O+',
                label: 'Blood Type',
                color: Color(0xFFBBDEFB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: DashboardCard(
                icon: Icons.calendar_today,
                value: '2',
                label: 'Upcoming',
                color: Color(0xFFC8E6C9),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                icon: Icons.emoji_events,
                value: '2',
                label: 'Badges Earned',
                color: Color(0xFFFFF9C4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        const Text(
          'Upcoming Appointments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        const AppointmentCard(
          center: 'City Blood Center',
          date: '2024-01-20 at 10:00 AM',
          location: '123 Health St, Downtown',
          status: 'confirmed',
          statusColor: Colors.green,
        ),
        const SizedBox(height: 12),
        const AppointmentCard(
          center: 'Memorial Hospital',
          date: '2024-03-15 at 2:00 PM',
          location: '456 Medical Ave, Midtown',
          status: 'pending',
          statusColor: Colors.orange,
        ),

        const SizedBox(height: 32),
        const Text(
          'Achievements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Row(
          children: const [
            Expanded(
              child: AchievementCard(
                title: 'First Donation',
                color: Color(0xFFFFF9C4),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: AchievementCard(
                title: 'Regular Donor',
                color: Color(0xFFBBDEFB),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
        
      ],
    );
  }
}

// ✅ Dashboard Card Widget
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ✅ Appointment Card Widget
class AppointmentCard extends StatelessWidget {
  final String center;
  final String date;
  final String location;
  final String status;
  final Color statusColor;

  const AppointmentCard({
    super.key,
    required this.center,
    required this.date,
    required this.location,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    Icon? statusIcon;

    if (status.toLowerCase() == 'confirmed') {
      statusIcon = const Icon(Icons.check_circle, color: Colors.green, size: 18);
    } else if (status.toLowerCase() == 'pending') {
      statusIcon = const Icon(Icons.hourglass_bottom, color: Colors.orange, size: 18);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(date),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(location),
                ],
              ),
              Row(
                children: [
                  if (statusIcon != null) statusIcon,
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ Achievement Card Widget
class AchievementCard extends StatelessWidget {
  final String title;
  final Color color;

  const AchievementCard({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, size: 36),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
