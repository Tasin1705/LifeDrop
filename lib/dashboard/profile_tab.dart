import 'package:flutter/material.dart';
import 'personal_info_screen.dart';
import 'donation_summary_screen.dart';
import 'blood_information_screen.dart';
import 'badges_screen.dart';
import 'health_medical_info_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF0F5), // Light pink background
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Solid green top section (no gradient)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.green, // Fully green with no transparency
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.green),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ahnaf Tahmid',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 🔴 Profile Info Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: Ahnaf Tahmid', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Email: ahnaf@email.com', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 🟢 Grid of buttons
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: [
                _buildProfileButton(
                  context,
                  icon: Icons.person,
                  label: 'Personal Info',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                  ),
                ),
                _buildProfileButton(
                  context,
                  icon: Icons.bloodtype,
                  label: 'Blood Info',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BloodInformationScreen()),
                  ),
                ),
                _buildProfileButton(
                  context,
                  icon: Icons.health_and_safety,
                  label: 'Health Info',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HealthAndMedicalInfoScreen()),
                  ),
                ),
                _buildProfileButton(
                  context,
                  icon: Icons.assignment,
                  label: 'Donations',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DonationSummaryScreen()),
                  ),
                ),
                _buildProfileButton(
                  context,
                  icon: Icons.emoji_events,
                  label: 'Badges',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BadgesScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade50,
        foregroundColor: Colors.green.shade800,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }
}
