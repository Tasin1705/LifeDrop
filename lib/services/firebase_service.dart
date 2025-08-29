import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Authentication Methods
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore Methods
  Future<void> createBloodRequest({
    required String hospitalId,
    required String bloodType,
    required int units,
    required String urgency,
    required String status,
  }) async {
    try {
      await _firestore.collection('blood_requests').add({
        'hospitalId': hospitalId,
        'bloodType': bloodType,
        'units': units,
        'urgency': urgency,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create blood request: $e');
    }
  }

  Stream<QuerySnapshot> getBloodRequests() {
    return _firestore
        .collection('blood_requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateBloodRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('blood_requests').doc(requestId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update blood request: $e');
    }
  }

  // Push Notification Methods
  Future<void> initNotifications() async {
    await _messaging.requestPermission();
    final fcmToken = await _messaging.getToken();

    if (fcmToken != null) {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': fcmToken,
        });
      }
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final fcmToken = userDoc.data()?['fcmToken'];

    if (fcmToken != null) {
      // Implement cloud function to send notification
      await _firestore.collection('notifications').add({
        'token': fcmToken,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
