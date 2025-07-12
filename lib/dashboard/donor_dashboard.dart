import 'package:flutter/material.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: const [
            TabBar(
              tabs: [
                Tab(icon: Icon(Icons.favorite), text: 'Overview'),
                Tab(icon: Icon(Icons.calendar_today), text: 'Schedule'),
                Tab(icon: Icon(Icons.history), text: 'History'),
                Tab(icon: Icon(Icons.person), text: 'Profile'),
              ],
              indicatorColor: Colors.red,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  OverviewTab(),
                  ScheduleTab(),
                  HistoryTab(),
                  ProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            'Welcome back, CHOCOS !\nThank you for being a life-saver. Your donations make a real difference.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DashboardCard(
              icon: Icons.favorite,
              value: '3',
              label: 'Total Donations',
              color: Colors.red.shade100,
            ),
            _DashboardCard(
              icon: Icons.bloodtype,
              value: 'O+',
              label: 'Blood Type',
              color: Colors.blue.shade100,
            ),
            _DashboardCard(
              icon: Icons.calendar_today,
              value: '2',
              label: 'Upcoming',
              color: Colors.green.shade100,
            ),
            _DashboardCard(
              icon: Icons.emoji_events,
              value: '2',
              label: 'Badges Earned',
              color: Colors.yellow.shade100,
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Upcoming Appointments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _AppointmentCard(
          center: 'City Blood Center',
          date: '2024-01-20 at 10:00 AM',
          location: '123 Health St, Downtown',
          status: 'confirmed',
          statusColor: Colors.green,
        ),
        const SizedBox(height: 16),
        _AppointmentCard(
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
          children: [
            _AchievementCard(
              title: 'First Donation',
              color: Colors.yellow.shade100,
            ),
            const SizedBox(width: 16),
            _AchievementCard(
              title: 'Regular Donor',
              color: Colors.blue.shade100,
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _DashboardCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
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

class _AppointmentCard extends StatelessWidget {
  final String center;
  final String date;
  final String location;
  final String status;
  final Color statusColor;

  const _AppointmentCard({
    required this.center,
    required this.date,
    required this.location,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(date),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  Text(location),
                ],
              ),
              Chip(
                label: Text(status),
                backgroundColor: statusColor.withOpacity(0.1),
                labelStyle: TextStyle(color: statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final Color color;

  const _AchievementCard({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
      ),
    );
  }
}

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Schedule Page'));
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('History Page'));
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Page'));
  }
}
