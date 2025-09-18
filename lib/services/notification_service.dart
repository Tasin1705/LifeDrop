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
    String? requestId, // ID of the blood request document
    String? requesterId, // ID of the requester (hospital/donor)
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
              'requestId': requestId,
              'requesterId': requesterId,
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

  // Send notification to all hospitals except the requester when blood is requested
  static Future<List<String>> sendBloodRequestNotificationToHospitals({
    required String bloodType,
    required String units,
    required String contact,
    required DateTime requiredDate,
    required double latitude,
    required double longitude,
    required String requesterName,
    required String requesterType, // 'Donor' or 'Hospital'
    String? requestId, // ID of the blood request document
    String? requesterId, // ID of the requester (hospital/donor)
  }) async {
    try {
      List<String> notifiedHospitals = [];
      
      print('=== SENDING HOSPITAL NOTIFICATIONS ===');
      print('Requester ID: $requesterId');
      print('Requester Type: $requesterType');
      print('Blood Type: $bloodType');
      
      // Get all hospitals except the requester
      final hospitalsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Hospital')
          .get();

      print('Total hospitals found: ${hospitalsQuery.docs.length}');

      for (var hospitalDoc in hospitalsQuery.docs) {
        final hospitalId = hospitalDoc.id;
        final hospitalData = hospitalDoc.data();
        final hospitalName = hospitalData['fullName'] ?? 'Unknown Hospital';
        
        print('Checking hospital: $hospitalName (ID: $hospitalId)');
        
        // Skip if this is the requesting hospital
        if (requesterId != null && hospitalId == requesterId) {
          print('Skipping requester hospital: $hospitalName');
          continue;
        }
        
        print('Sending notification to hospital: $hospitalName');
        
        await _createNotification(
          userId: hospitalId,
          title: 'Emergency Blood Request - $bloodType',
          message: '$requesterType needs $units units of $bloodType blood urgently. Required by ${_formatDate(requiredDate)}. Contact: $contact',
          type: 'hospital_blood_request',
          data: {
            'bloodType': bloodType,
            'units': units,
            'contact': contact,
            'requiredDate': Timestamp.fromDate(requiredDate),
            'latitude': latitude,
            'longitude': longitude,
            'requesterName': requesterName,
            'requesterType': requesterType,
            'requestId': requestId,
            'requesterId': requesterId,
            'priority': 'high',
          },
        );
        
        notifiedHospitals.add(hospitalId);
        print('Notification sent successfully to: $hospitalName');
      }
      
      print('Total hospitals notified: ${notifiedHospitals.length}');
      print('======================================');
      
      return notifiedHospitals;
    } catch (e) {
      print('Error sending blood request notification to hospitals: $e');
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
      print('Creating notification for user: $userId, type: $type, title: $title');
      
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'data': data ?? {},
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
      
      print('Notification created successfully for user: $userId');
    } catch (e) {
      print('Error creating notification for user $userId: $e');
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

  // Send confirmation notification when hospital confirms blood donation
  static Future<void> sendBloodRequestConfirmation({
    required String donorId,
    required String hospitalName,
    required String bloodType,
    required String units,
    required String requestId,
    required String acceptanceId,
  }) async {
    try {
      await _createNotification(
        userId: donorId,
        title: 'Blood Donation Confirmed!',
        message: '$hospitalName has confirmed your blood donation of $units units of $bloodType. Thank you for saving lives!',
        type: 'request_confirmed',
        data: {
          'hospitalName': hospitalName,
          'bloodType': bloodType,
          'units': units,
          'requestId': requestId,
          'acceptanceId': acceptanceId,
          'confirmedAt': Timestamp.now(),
        },
      );
    } catch (e) {
      print('Error sending confirmation notification: $e');
    }
  }

  // Debug function to test hospital notifications
  static Future<void> testHospitalNotifications() async {
    try {
      print('=== TESTING HOSPITAL NOTIFICATIONS ===');
      
      // Get all hospitals
      final hospitalsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Hospital')
          .get();

      print('Found ${hospitalsQuery.docs.length} hospitals in database');
      
      for (var hospitalDoc in hospitalsQuery.docs) {
        final hospitalData = hospitalDoc.data();
        final hospitalName = hospitalData['fullName'] ?? 'Unknown Hospital';
        print('Hospital found: $hospitalName (ID: ${hospitalDoc.id})');
        
        // Send a test notification to each hospital
        await _createNotification(
          userId: hospitalDoc.id,
          title: 'Test Notification',
          message: 'This is a test notification to verify the system is working.',
          type: 'test',
          data: {
            'test': true,
            'createdAt': Timestamp.now(),
          },
        );
        
        print('Test notification sent to: $hospitalName');
      }
      
      print('=== TEST COMPLETED ===');
    } catch (e) {
      print('Error in test function: $e');
    }
  }

  // Send notification when hospital accepts a blood request
  static Future<void> sendBloodRequestAcceptanceToRequester({
    required String requesterId,
    required String hospitalName,
    required String hospitalContact,
    required String bloodType,
    required String units,
    required String requestId,
    required String hospitalId,
  }) async {
    try {
      await _createNotification(
        userId: requesterId,
        title: 'Blood Request Accepted!',
        message: '$hospitalName has accepted your $bloodType blood request for $units units. Contact: $hospitalContact',
        type: 'hospital_request_accepted',
        data: {
          'hospitalName': hospitalName,
          'hospitalContact': hospitalContact,
          'hospitalId': hospitalId,
          'bloodType': bloodType,
          'units': units,
          'requestId': requestId,
          'acceptedAt': Timestamp.now(),
        },
      );
    } catch (e) {
      print('Error sending hospital acceptance notification: $e');
    }
  }
}
