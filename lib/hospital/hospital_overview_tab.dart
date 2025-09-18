import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalOverviewTab extends StatefulWidget {
  const HospitalOverviewTab({super.key});

  @override
  State<HospitalOverviewTab> createState() => _HospitalOverviewTabState();
}

class _HospitalOverviewTabState extends State<HospitalOverviewTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        return Text(
                          'Welcome, ${data['fullName'] ?? 'Hospital'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        );
                      }
                      return const Text(
                        'Welcome to LifeDrop',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Requests',
                    Icons.bloodtype,
                    Colors.red,
                    _getActiveRequestsCount(),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    'Total Donors',
                    Icons.people,
                    Colors.blue,
                    _getTotalDonorsWhoAcceptedCount(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'This Month',
                    Icons.calendar_month,
                    Colors.green,
                    _getThisMonthRequestsCount(),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    'Accepted Requests',
                    Icons.check_circle,
                    Colors.orange,
                    _getAcceptedRequestsCount(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Recent Activity
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Blood Requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildRecentRequests(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color, Stream<int> countStream) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 30),
              StreamBuilder<int>(
                stream: countStream,
                builder: (context, snapshot) {
                  return Text(
                    '${snapshot.data ?? 0}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('blood_requests')
          .where('requesterId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No recent requests',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // Sort manually and take first 5
        final docs = snapshot.data!.docs;
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return bTime.compareTo(aTime); // Descending order (newest first)
        });
        
        final limitedDocs = docs.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: limitedDocs.length,
          itemBuilder: (context, index) {
            final doc = limitedDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(
                    color: Colors.red,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data['bloodType'] ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data['units'] ?? 'N/A'} units required',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<String>(
                    future: _getRequestStatus(doc.id),
                    builder: (context, snapshot) {
                      final status = snapshot.data ?? 'pending';
                      
                      // Only show status badge for confirmed and rejected, not pending
                      if (status == 'pending') {
                        return const SizedBox.shrink();
                      }
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'accepted':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<String> _getRequestStatus(String requestId) async {
    try {
      // Check if there are any acceptances for this request
      final acceptanceQuery = await FirebaseFirestore.instance
          .collection('blood_acceptances')
          .where('requestId', isEqualTo: requestId)
          .get();

      if (acceptanceQuery.docs.isEmpty) {
        return 'pending'; // No one has accepted yet
      }

      // Check if any acceptance is confirmed
      for (final doc in acceptanceQuery.docs) {
        final data = doc.data();
        if (data['status'] == 'confirmed') {
          return 'confirmed';
        }
      }

      // If there are acceptances but none confirmed, status is accepted
      return 'accepted';
    } catch (e) {
      return 'pending';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Stream<int> _getActiveRequestsCount() {
    return FirebaseFirestore.instance
        .collection('blood_requests')
        .where('requesterId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .asyncMap((snapshot) async {
          int activeCount = 0;
          
          for (final doc in snapshot.docs) {
            final requestId = doc.id;
            
            // Check if this request has any confirmed acceptances
            final confirmedAcceptances = await FirebaseFirestore.instance
                .collection('blood_acceptances')
                .where('requestId', isEqualTo: requestId)
                .where('status', isEqualTo: 'confirmed')
                .get();
            
            // If no confirmed acceptances, it's still active
            if (confirmedAcceptances.docs.isEmpty) {
              activeCount++;
            }
          }
          
          return activeCount;
        });
  }

  Stream<int> _getTotalDonorsWhoAcceptedCount() {
    return FirebaseFirestore.instance
        .collection('blood_acceptances')
        .where('hospitalId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snapshot) {
          // Get unique donor IDs who have confirmed requests from this hospital
          final uniqueDonorIds = <String>{};
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final donorId = data['donorId'] as String?;
            if (donorId != null) {
              uniqueDonorIds.add(donorId);
            }
          }
          return uniqueDonorIds.length;
        });
  }

  Stream<int> _getThisMonthRequestsCount() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return FirebaseFirestore.instance
        .collection('blood_requests')
        .where('requesterId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.where((doc) {
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          return createdAt != null && createdAt.isAfter(startOfMonth);
        }).length);
  }

  Stream<int> _getAcceptedRequestsCount() {
    return FirebaseFirestore.instance
        .collection('blood_acceptances')
        .where('hospitalId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
