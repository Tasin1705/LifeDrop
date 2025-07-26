import 'package:flutter/material.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final historyRecords = [
      {
        'date': '2023-11-25',
        'location': 'City Blood Center',
        'bloodType': 'O+',
        'amount': '450ml',
        'donationType': 'Whole Blood',
      },
      {
        'date': '2023-08-20',
        'location': 'Community Hospital',
        'bloodType': 'O+',
        'amount': '450ml',
        'donationType': 'Platelets',
      },
      {
        'date': '2023-05-10',
        'location': 'Red Cross Center',
        'bloodType': 'O+',
        'amount': '450ml',
        'donationType': 'Double Red Cells',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Donation History',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // 🧾 Row cards
        ...historyRecords.map((record) {
          final originalDate = DateTime.parse(record['date']!);
          final nextEligible = originalDate.add(const Duration(days: 90));
          final nextEligibleStr =
              "${nextEligible.year}-${nextEligible.month.toString().padLeft(2, '0')}-${nextEligible.day.toString().padLeft(2, '0')}";

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Date & Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        record['date']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(record['location']!),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Blood info row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoBadge(
                        icon: Icons.bloodtype,
                        label: 'Blood Type',
                        value: record['bloodType']!,
                        color: Colors.red.shade100,
                      ),
                      _InfoBadge(
                        icon: Icons.opacity,
                        label: 'Amount',
                        value: record['amount']!,
                        color: Colors.blue.shade100,
                      ),
                      _InfoBadge(
                        icon: Icons.local_hospital,
                        label: 'Type',
                        value: record['donationType']!,
                        color: Colors.purple.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Status & Next Eligible
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: const Text('Completed'),
                        backgroundColor: Colors.green.shade100,
                        labelStyle: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16),
                          const SizedBox(width: 4),
                          Text("Next Eligible: $nextEligibleStr"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
