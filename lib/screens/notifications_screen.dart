import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view notifications'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () => _markAllAsRead(user.uid),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationService.getUserNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString().contains('permission-denied')
                        ? 'Permission denied. Please check Firestore security rules.'
                        : snapshot.error.toString(),
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort notifications by creation date manually (newest first)
          notifications.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            return bTime.compareTo(aTime); // Descending order (newest first)
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final data = notification.data() as Map<String, dynamic>;
              final isRead = data['isRead'] as bool? ?? false;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              final type = data['type'] as String? ?? 'general';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: isRead ? Colors.white : Colors.red.shade50,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getNotificationColor(type),
                    child: Icon(
                      _getNotificationIcon(type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data['title'] ?? 'Notification',
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['message'] ?? '',
                        style: TextStyle(
                          color: isRead ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      // Quick call button for blood requests
                      if (type == 'blood_request')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              FutureBuilder<bool>(
                                future: _checkIfRequestAccepted(data['data'] as Map<String, dynamic>? ?? {}),
                                builder: (context, snapshot) {
                                  final isAccepted = snapshot.data ?? false;
                                  
                                  if (isAccepted) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.pending, size: 16, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Pending', style: TextStyle(fontSize: 12, color: Colors.white)),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  return ElevatedButton.icon(
                                    onPressed: () async {
                                      final notificationData = data['data'] as Map<String, dynamic>? ?? {};
                                      await _acceptBloodRequest(context, notificationData, notification.id);
                                    },
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Accept', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      // Accept button for hospital blood requests
                      if (type == 'hospital_blood_request')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              FutureBuilder<bool>(
                                future: _checkIfHospitalRequestAccepted(data['data'] as Map<String, dynamic>? ?? {}),
                                builder: (context, snapshot) {
                                  final isAccepted = snapshot.data ?? false;
                                  
                                  if (isAccepted) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, size: 16, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Accepted', style: TextStyle(fontSize: 12, color: Colors.white)),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  return ElevatedButton.icon(
                                    onPressed: () async {
                                      final notificationData = data['data'] as Map<String, dynamic>? ?? {};
                                      await _acceptHospitalBloodRequest(context, notificationData, notification.id);
                                    },
                                    icon: const Icon(Icons.local_hospital, size: 16),
                                    label: const Text('Accept Request', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      // Confirm/Reject buttons for hospitals when donor accepts their request
                      if (type == 'request_accepted')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              FutureBuilder<String>(
                                future: _checkRequestStatus(data['data'] as Map<String, dynamic>? ?? {}),
                                builder: (context, snapshot) {
                                  final status = snapshot.data ?? 'pending';
                                  
                                  if (status == 'confirmed') {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, size: 16, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Confirmed', style: TextStyle(fontSize: 12, color: Colors.white)),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  if (status == 'rejected') {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.cancel, size: 16, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Rejected', style: TextStyle(fontSize: 12, color: Colors.white)),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  // For accepted status, show confirmation buttons
                                  if (status == 'accepted') {
                                    return Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _confirmBloodDonation(context, data['data'] as Map<String, dynamic>? ?? {}, notification.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            minimumSize: const Size(0, 32),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check, size: 16),
                                              SizedBox(width: 4),
                                              Text('Confirm', style: TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => _rejectBloodDonation(context, data['data'] as Map<String, dynamic>? ?? {}, notification.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            minimumSize: const Size(0, 32),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.close, size: 16),
                                              SizedBox(width: 4),
                                              Text('Reject', style: TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  
                                  // For other statuses, show nothing
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await NotificationService.deleteNotification(notification.id);
                    },
                    tooltip: 'Delete notification',
                  ),
                  onTap: () async {
                    if (!isRead) {
                      await NotificationService.markNotificationAsRead(notification.id);
                    }
                    
                    // Show notification details based on type
                    _showNotificationDetails(context, data, type);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'blood_request':
        return Icons.bloodtype;
      case 'hospital_blood_request':
        return Icons.local_hospital;
      case 'donation_reminder':
        return Icons.schedule;
      case 'request_accepted':
        return Icons.check_circle;
      case 'hospital_request_accepted':
        return Icons.verified;
      case 'request_approved':
        return Icons.verified;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'blood_request':
        return Colors.red;
      case 'hospital_blood_request':
        return Colors.red.shade700;
      case 'donation_reminder':
        return Colors.orange;
      case 'request_accepted':
        return Colors.green;
      case 'hospital_request_accepted':
        return Colors.blue;
      case 'request_approved':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _markAllAsRead(String userId) async {
    try {
      final notifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking notifications as read: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> data, String type) {
    final notificationData = data['data'] as Map<String, dynamic>? ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getNotificationTitle(type, notificationData)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (type == 'blood_request' || type == 'hospital_blood_request') ...[
                _buildDetailRow('Blood Type:', notificationData['bloodType'] ?? 'Unknown'),
                _buildDetailRow('Units Required:', notificationData['units'] ?? 'Unknown'),
                _buildDetailRow('Contact:', notificationData['contact'] ?? 'Unknown'),
                _buildDetailRow('Requester:', '${notificationData['requesterName'] ?? 'Unknown'} (${notificationData['requesterType'] ?? 'Unknown'})'),
                if (notificationData['requiredDate'] != null)
                  _buildDetailRow('Required By:', _formatDate((notificationData['requiredDate'] as Timestamp?)?.toDate() ?? DateTime.now())),
                if (type == 'hospital_blood_request')
                  _buildDetailRow('Priority:', notificationData['priority'] ?? 'Normal'),
              ],
              if (type == 'request_accepted') ...[
                _buildDetailRow('Donor:', notificationData['donorName'] ?? 'Unknown'),
                _buildDetailRow('Blood Type:', notificationData['bloodType'] ?? 'Unknown'),
                _buildDetailRow('Units:', notificationData['units'] ?? 'Unknown'),
                _buildDetailRow('Contact:', notificationData['donorContact'] ?? 'Unknown'),
                if (notificationData['acceptedAt'] != null)
                  _buildDetailRow('Accepted At:', _formatDate((notificationData['acceptedAt'] as Timestamp?)?.toDate() ?? DateTime.now())),
              ],
              if (type == 'hospital_request_accepted') ...[
                _buildDetailRow('Hospital:', notificationData['hospitalName'] ?? 'Unknown'),
                _buildDetailRow('Blood Type:', notificationData['bloodType'] ?? 'Unknown'),
                _buildDetailRow('Units:', notificationData['units'] ?? 'Unknown'),
                _buildDetailRow('Hospital Contact:', notificationData['hospitalContact'] ?? 'Unknown'),
                if (notificationData['acceptedAt'] != null)
                  _buildDetailRow('Accepted At:', _formatDate((notificationData['acceptedAt'] as Timestamp?)?.toDate() ?? DateTime.now())),
              ],
              if (type == 'request_confirmed') ...[
                _buildDetailRow('Status:', 'Confirmed'),
                _buildDetailRow('Blood Type:', notificationData['bloodType'] ?? 'Unknown'),
                _buildDetailRow('Units:', notificationData['units'] ?? 'Unknown'),
                if (notificationData['confirmedAt'] != null)
                  _buildDetailRow('Confirmed At:', _formatDate((notificationData['confirmedAt'] as Timestamp?)?.toDate() ?? DateTime.now())),
              ],
              if (type == 'request_rejected') ...[
                _buildDetailRow('Status:', 'Rejected'),
                _buildDetailRow('Blood Type:', notificationData['bloodType'] ?? 'Unknown'),
                _buildDetailRow('Units:', notificationData['units'] ?? 'Unknown'),
                if (notificationData['rejectedAt'] != null)
                  _buildDetailRow('Rejected At:', _formatDate((notificationData['rejectedAt'] as Timestamp?)?.toDate() ?? DateTime.now())),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getNotificationTitle(String type, Map<String, dynamic> notificationData) {
    switch (type) {
      case 'blood_request':
        return 'Blood Request - ${notificationData['bloodType'] ?? 'Unknown'}';
      case 'hospital_blood_request':
        return 'Emergency Blood Request - ${notificationData['bloodType'] ?? 'Unknown'}';
      case 'request_accepted':
        return 'Donation Accepted';
      case 'hospital_request_accepted':
        return 'Hospital Response';
      case 'request_confirmed':
        return 'Donation Confirmed';
      case 'request_rejected':
        return 'Donation Rejected';
      default:
        return 'Notification Details';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptBloodRequest(BuildContext context, Map<String, dynamic> notificationData, String notificationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Debug: Print all notification data to understand the structure
      print('=== ACCEPT BLOOD REQUEST DEBUG ===');
      print('Full notification data: $notificationData');
      print('RequestId from notification: ${notificationData['requestId']}');
      print('RequesterId from notification: ${notificationData['requesterId']}');
      print('=====================================');

      // Get donor information
      final donorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final donorData = donorDoc.data() ?? {};
      final donorName = donorData['fullName'] ?? 'Unknown Donor';

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Accept Blood Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to accept this blood request?'),
              const SizedBox(height: 16),
              _buildDetailRow('Blood Type:', notificationData['bloodType'] ?? 'Unknown'),
              _buildDetailRow('Units Required:', notificationData['units'] ?? 'Unknown'),
              _buildDetailRow('Requester:', '${notificationData['requesterName'] ?? 'Unknown'}'),
              _buildDetailRow('Contact:', notificationData['contact'] ?? 'Unknown'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Accept', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Create acceptance record
      await FirebaseFirestore.instance.collection('blood_acceptances').add({
        'requestId': notificationData['requestId'] ?? '',
        'donorId': user.uid,
        'donorName': donorName,
        'hospitalId': notificationData['requesterId'] ?? '',
        'hospitalName': notificationData['requesterName'] ?? '',
        'bloodType': notificationData['bloodType'],
        'units': notificationData['units'],
        'contact': notificationData['contact'],
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'donorContact': donorData['phone'] ?? '',
      });

      // Debug: Print the original notification data to see what requestId we have
      print('Original notification data: $notificationData');
      print('RequestId being used: ${notificationData['requestId']}');

      // Send notification to hospital about the acceptance
      await NotificationService.sendNotificationToUser(
        userId: notificationData['requesterId'] ?? '',
        title: 'Blood Request Accepted!',
        message: 'Donor $donorName has accepted your ${notificationData['bloodType']} blood request. Contact: ${donorData['phone'] ?? 'No contact'}',
        type: 'request_accepted',
        data: {
          'donorId': user.uid,
          'donorName': donorName,
          'donorContact': donorData['phone'] ?? '',
          'bloodType': notificationData['bloodType'],
          'units': notificationData['units'],
          'requestId': notificationData['requestId'] ?? '', // Make sure this is included
          'hospitalId': notificationData['requesterId'] ?? '',
          'hospitalName': notificationData['requesterName'] ?? '',
          'acceptedAt': FieldValue.serverTimestamp(),
        },
      );

      // Mark the notification as read
      await NotificationService.markNotificationAsRead(notificationId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blood request accepted! Hospital has been notified.'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<bool> _checkIfRequestAccepted(Map<String, dynamic> notificationData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final requestId = notificationData['requestId'] ?? '';
      if (requestId.isEmpty) return false;

      final acceptanceQuery = await FirebaseFirestore.instance
          .collection('blood_acceptances')
          .where('requestId', isEqualTo: requestId)
          .where('donorId', isEqualTo: user.uid)
          .get();

      return acceptanceQuery.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkIfHospitalRequestAccepted(Map<String, dynamic> notificationData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final requestId = notificationData['requestId'] ?? '';
      if (requestId.isEmpty) return false;

      final acceptanceQuery = await FirebaseFirestore.instance
          .collection('hospital_blood_acceptances')
          .where('requestId', isEqualTo: requestId)
          .where('hospitalId', isEqualTo: user.uid)
          .get();

      return acceptanceQuery.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String> _checkRequestStatus(Map<String, dynamic> notificationData) async {
    try {
      final donorId = notificationData['donorId'] ?? '';
      final requestId = notificationData['requestId'] ?? '';
      if (donorId.isEmpty || requestId.isEmpty) return 'accepted';

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'accepted';

      final acceptanceQuery = await FirebaseFirestore.instance
          .collection('blood_acceptances')
          .where('donorId', isEqualTo: donorId)
          .where('hospitalId', isEqualTo: user.uid)
          .where('requestId', isEqualTo: requestId)
          .get();

      if (acceptanceQuery.docs.isNotEmpty) {
        final status = acceptanceQuery.docs.first.data()['status'] ?? 'accepted';
        return status;
      }

      return 'accepted';
    } catch (e) {
      return 'accepted';
    }
  }

  Future<void> _confirmBloodDonation(BuildContext context, Map<String, dynamic> notificationData, String notificationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Debug: Print the notification data to understand the structure
      print('Notification data: $notificationData');

      final donorId = notificationData['donorId'] ?? '';
      final requestId = notificationData['requestId'] ?? '';
      final donorName = notificationData['donorName'] ?? 'Unknown Donor';
      final bloodType = notificationData['bloodType'] ?? '';
      final units = notificationData['units'] ?? '';

      // Debug: Print individual values
      print('donorId: $donorId');
      print('requestId: $requestId');
      print('donorName: $donorName');
      print('bloodType: $bloodType');
      print('units: $units');

      if (donorId.isEmpty || requestId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Missing donation information. DonorId: $donorId, RequestId: $requestId'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get hospital information
      final hospitalDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final hospitalData = hospitalDoc.data() ?? {};
      final hospitalName = hospitalData['fullName'] ?? 'Unknown Hospital';

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Blood Donation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to confirm this blood donation?'),
              const SizedBox(height: 16),
              _buildDetailRow('Donor:', donorName),
              _buildDetailRow('Blood Type:', bloodType),
              _buildDetailRow('Units:', units),
              const SizedBox(height: 8),
              Text(
                'This will notify the donor that their donation has been confirmed.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Update acceptance status to confirmed
      final acceptanceQuery = await FirebaseFirestore.instance
          .collection('blood_acceptances')
          .where('donorId', isEqualTo: donorId)
          .where('hospitalId', isEqualTo: user.uid)
          .where('requestId', isEqualTo: requestId)
          .get();

      if (acceptanceQuery.docs.isNotEmpty) {
        final acceptanceDoc = acceptanceQuery.docs.first;
        await acceptanceDoc.reference.update({
          'status': 'confirmed',
          'confirmedAt': FieldValue.serverTimestamp(),
          'confirmedBy': user.uid,
        });

        // Send confirmation notification to donor
        await NotificationService.sendBloodRequestConfirmation(
          donorId: donorId,
          hospitalName: hospitalName,
          bloodType: bloodType,
          units: units,
          requestId: requestId,
          acceptanceId: acceptanceDoc.id,
        );

        // Create donation history record
        await FirebaseFirestore.instance.collection('donation_history').add({
          'donorId': donorId,
          'donorName': donorName,
          'hospitalId': user.uid,
          'hospitalName': hospitalName,
          'bloodType': bloodType,
          'units': units,
          'requestId': requestId,
          'acceptanceId': acceptanceDoc.id,
          'donationDate': FieldValue.serverTimestamp(),
          'status': 'completed',
          'donorContact': notificationData['donorContact'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update donor's last donation date
        await FirebaseFirestore.instance
            .collection('users')
            .doc(donorId)
            .update({
          'lastDonation': FieldValue.serverTimestamp(),
        });

        // Mark the notification as read
        await NotificationService.markNotificationAsRead(notificationId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blood donation confirmed! Donor has been notified.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming donation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectBloodDonation(BuildContext context, Map<String, dynamic> notificationData, String notificationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final donorId = notificationData['donorId'] ?? '';
      final requestId = notificationData['requestId'] ?? '';
      final donorName = notificationData['donorName'] ?? 'Unknown Donor';
      final bloodType = notificationData['bloodType'] ?? '';
      final units = notificationData['units'] ?? '';

      if (donorId.isEmpty || requestId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Missing donation information'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get hospital information
      final hospitalDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final hospitalData = hospitalDoc.data() ?? {};
      final hospitalName = hospitalData['fullName'] ?? 'Unknown Hospital';

      // Show rejection dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reject Blood Donation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to reject this blood donation?'),
              const SizedBox(height: 16),
              _buildDetailRow('Donor:', donorName),
              _buildDetailRow('Blood Type:', bloodType),
              _buildDetailRow('Units:', units),
              const SizedBox(height: 8),
              Text(
                'This will notify the donor that their donation has been rejected.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Update acceptance status to rejected
      final acceptanceQuery = await FirebaseFirestore.instance
          .collection('blood_acceptances')
          .where('donorId', isEqualTo: donorId)
          .where('hospitalId', isEqualTo: user.uid)
          .where('requestId', isEqualTo: requestId)
          .get();

      if (acceptanceQuery.docs.isNotEmpty) {
        final acceptanceDoc = acceptanceQuery.docs.first;
        await acceptanceDoc.reference.update({
          'status': 'rejected',
          'rejectedAt': FieldValue.serverTimestamp(),
          'rejectedBy': user.uid,
        });

        // Send rejection notification to donor
        await NotificationService.sendNotificationToUser(
          userId: donorId,
          title: 'Blood Donation Rejected',
          message: '$hospitalName has rejected your blood donation for $units units of $bloodType. Thank you for your willingness to help.',
          type: 'request_rejected',
          data: {
            'hospitalName': hospitalName,
            'bloodType': bloodType,
            'units': units,
            'requestId': requestId,
            'rejectedAt': FieldValue.serverTimestamp(),
          },
        );

        // Mark the notification as read
        await NotificationService.markNotificationAsRead(notificationId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blood donation rejected. Donor has been notified.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting donation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _acceptHospitalBloodRequest(BuildContext context, Map<String, dynamic> notificationData, String notificationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get hospital information
      final hospitalDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final hospitalData = hospitalDoc.data() ?? {};
      final hospitalName = hospitalData['fullName'] ?? 'Unknown Hospital';
      final hospitalContact = hospitalData['phone'] ?? 'No contact available';

      final requesterId = notificationData['requesterId'] ?? '';
      final requesterName = notificationData['requesterName'] ?? 'Unknown';
      final bloodType = notificationData['bloodType'] ?? '';
      final units = notificationData['units'] ?? '';
      final requestId = notificationData['requestId'] ?? '';

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Accept Blood Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to accept this blood request?'),
              const SizedBox(height: 16),
              _buildDetailRow('Requester:', requesterName),
              _buildDetailRow('Blood Type:', bloodType),
              _buildDetailRow('Units Required:', units),
              const SizedBox(height: 8),
              Text(
                'The requester will be notified that your hospital can provide the requested blood.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Accept Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Create hospital acceptance record
      await FirebaseFirestore.instance.collection('hospital_blood_acceptances').add({
        'requestId': requestId,
        'hospitalId': user.uid,
        'hospitalName': hospitalName,
        'hospitalContact': hospitalContact,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'bloodType': bloodType,
        'units': units,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to the requester
      await NotificationService.sendBloodRequestAcceptanceToRequester(
        requesterId: requesterId,
        hospitalName: hospitalName,
        hospitalContact: hospitalContact,
        bloodType: bloodType,
        units: units,
        requestId: requestId,
        hospitalId: user.uid,
      );

      // Mark the notification as read
      await NotificationService.markNotificationAsRead(notificationId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blood request accepted! Requester has been notified.'),
          backgroundColor: Colors.blue,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
