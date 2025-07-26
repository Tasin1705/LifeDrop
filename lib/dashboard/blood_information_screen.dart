import 'package:flutter/material.dart';

class BloodInformationScreen extends StatefulWidget {
  const BloodInformationScreen({super.key});

  @override
  State<BloodInformationScreen> createState() => _BloodInformationScreenState();
}

class _BloodInformationScreenState extends State<BloodInformationScreen> {
  String bloodGroup = 'O+';
  String rhFactor = 'Positive';
  String donationPreference = 'Whole blood, Plasma, Platelets';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Soft gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFE5E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ✅ Title and Edit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.water_drop_rounded,
                          size: 32, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text(
                        'Blood Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.redAccent),
                    onPressed: () {
                      _showEditDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ✅ Section label
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Your Blood Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Info Cards
              _infoCard(
                title: 'Blood Group',
                value: bloodGroup,
                icon: Icons.bloodtype,
                color: Colors.red.shade100,
              ),
              const SizedBox(height: 16),
              _infoCard(
                title: 'Rh Factor',
                value: rhFactor,
                icon: Icons.info_outline,
                color: Colors.blue.shade100,
              ),
              const SizedBox(height: 16),
              _infoCard(
                title: 'Donation Type Preference',
                value: donationPreference,
                icon: Icons.favorite,
                color: Colors.green.shade100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Info card (simple, clean)
  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(icon, size: 28, color: Colors.redAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Edit dialog
  void _showEditDialog(BuildContext context) {
    final TextEditingController bloodController =
        TextEditingController(text: bloodGroup);
    final TextEditingController rhController =
        TextEditingController(text: rhFactor);
    final TextEditingController donationController =
        TextEditingController(text: donationPreference);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Blood Information'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: bloodController,
                  decoration:
                      const InputDecoration(labelText: 'Blood Group'),
                ),
                TextField(
                  controller: rhController,
                  decoration: const InputDecoration(labelText: 'Rh Factor'),
                ),
                TextField(
                  controller: donationController,
                  decoration: const InputDecoration(
                      labelText: 'Donation Preference'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                setState(() {
                  bloodGroup = bloodController.text;
                  rhFactor = rhController.text;
                  donationPreference = donationController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
