import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send notification to eligible donors when blood is requested
  static Future<List<String>> sendBloodRequestNotification({
    required String bloodType,
    required String units,
    required String contact,
    required DateTime requiredDate,
    required double latitude,
    required double longitude,
    required String requesterName,
    required String requesterType, // 'Donor' or 'Hospital'
  }) async {
    try {
      List<String> notifiedUsers = [];
      
      // Get all donors with the matching blood type
      final donorsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Donor')
          .where('bloodType', isEqualTo: bloodType)
          .get();

      for (var donorDoc in donorsQuery.docs) {
        final donorData = donorDoc.data();
        final donorId = donorDoc.id;
        
        // Check if donor is eligible (3 months gap from last donation)
        final lastDonation = donorData['lastDonation'] as Timestamp?;
        bool isEligible = true;
        
        if (lastDonation != null) {
          final lastDonationDate = lastDonation.toDate();
          final daysSinceLastDonation = DateTime.now().difference(lastDonationDate).inDays;
          isEligible = daysSinceLastDonation >= 90; // 3 months = 90 days
        }
        
        // Only send notification to eligible donors
        if (isEligible) {
          await _createNotification(
            userId: donorId,
            title: 'Blood Request - $bloodType',
            message: '$requesterType needs $units units of $bloodType blood. Required by ${_formatDate(requiredDate)}. Contact: $contact',
            type: 'blood_request',
            data: {
              'bloodType': bloodType,
              'units': units,
              'contact': contact,
              'requiredDate': Timestamp.fromDate(requiredDate),
              'latitude': latitude,
              'longitude': longitude,
              'requesterName': requesterName,
              'requesterType': requesterType,
            },
          );
          
          notifiedUsers.add(donorId);
        }
      }
      
      return notifiedUsers;
    } catch (e) {
      print('Error sending blood request notification: $e');
      return [];
    }
  }

  // Create a notification document in Firestore
  static Future<void> _createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'data': data ?? {},
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Get notifications for a specific user (simplified query to avoid index requirement)
  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Alternative method with ordering (requires index)
  static Stream<QuerySnapshot> getUserNotificationsOrdered(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get unread notification count for a user
  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final query = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      return query.docs.length;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Delete a notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Helper method to format date
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Send general notification to a specific user
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    await _createNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
      data: data,
    );
  }
}
