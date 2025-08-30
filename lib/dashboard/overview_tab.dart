import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  String userName = 'User';
  String userRole = '';
  DateTime? lastDonationDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          final fullName = userData['fullName'] as String?;
          setState(() {
            if (fullName != null && fullName.isNotEmpty) {
              userName = fullName.split(' ').first; // Use first name only
            }
            userRole = userData['role'] as String? ?? '';
            lastDonationDate = userData['lastDonation'] != null 
                ? (userData['lastDonation'] as Timestamp?)?.toDate() 
                : null;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user name: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 112, 85, 84),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Welcome back $userName!\nThank you for being a life-saver. Your donations make a real difference.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Donation Eligibility Box for Donors
        if (userRole == 'Donor' && !isLoading)
          Column(
            children: [
              _buildDonationEligibilityBox(),
              const SizedBox(height: 24),
            ],
          ),

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

  Widget _buildDonationEligibilityBox() {
    if (lastDonationDate == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Donation Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Eligible to Donate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You haven\'t donated blood yet. You are eligible to donate.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _recordDonation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Record Donation',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final nextEligibleDate = lastDonationDate!.add(const Duration(days: 90)); // 3 months = 90 days
    final daysRemaining = nextEligibleDate.difference(now).inDays;
    final isEligible = now.isAfter(nextEligibleDate) || now.isAtSameMomentAs(nextEligibleDate);

    if (isEligible) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Donation Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Eligible to Donate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last donation: ${_formatDate(lastDonationDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _recordDonation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Record Donation',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Donation Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Not Eligible',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last donation: ${_formatDate(lastDonationDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Days Remaining:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$daysRemaining days',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Next Eligible Date:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _formatDate(nextEligibleDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _recordDonation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Blood Donation'),
        content: const Text('Are you sure you want to record a blood donation today? This will start a 3-month countdown before you can donate again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'lastDonation': Timestamp.fromDate(DateTime.now()),
            'totalDonations': FieldValue.increment(1),
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Blood donation recorded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          _loadUserName(); // Reload the data
        }
      } catch (e) {
        print('Error recording donation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to record donation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
