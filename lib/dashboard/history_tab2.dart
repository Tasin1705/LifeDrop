import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Center(
        child: Text('Please log in to view donation history'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donation_history')
          .where('donorId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        var historyRecords = snapshot.data?.docs ?? [];
        
        // Sort the records by donation date in descending order (most recent first)
        historyRecords.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aDate = (aData['donationDate'] as Timestamp?)?.toDate() ?? DateTime(1970);
          final bDate = (bData['donationDate'] as Timestamp?)?.toDate() ?? DateTime(1970);
          return bDate.compareTo(aDate); // Descending order
        });

        if (historyRecords.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No donation history found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Your donation history will appear here after your first donation',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Donation History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dynamic donation records
            ...historyRecords.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final donationDate = (data['donationDate'] as Timestamp?)?.toDate() ?? DateTime.now();
              final nextEligible = donationDate.add(const Duration(days: 90));
              
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
                            _formatDate(donationDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(data['hospitalName'] ?? 'Unknown Hospital'),
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
                            value: data['bloodType'] ?? 'Unknown',
                            color: Colors.red.shade100,
                          ),
                          _InfoBadge(
                            icon: Icons.opacity,
                            label: 'Amount',
                            value: data['units'] ?? '450ml',
                            color: Colors.blue.shade100,
                          ),
                          _InfoBadge(
                            icon: Icons.local_hospital,
                            label: 'Status',
                            value: _getStatusDisplay(data['status'] ?? 'completed'),
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
                            label: Text(_getStatusDisplay(data['status'] ?? 'completed')),
                            backgroundColor: _getStatusColor(data['status'] ?? 'completed'),
                            labelStyle: TextStyle(
                              color: _getStatusTextColor(data['status'] ?? 'completed'),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 16),
                              const SizedBox(width: 4),
                              Text("Next Eligible: ${_formatDate(nextEligible)}"),
                            ],
                          ),
                        ],
                      ),

                      // Additional information if available
                      if (data['donorContact'] != null || data['notes'] != null) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        if (data['donorContact'] != null)
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('Contact: ${data['donorContact']}'),
                            ],
                          ),
                        if (data['notes'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.note, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Notes: ${data['notes']}')),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.orange.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
