import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// ✅ Save a new user profile to Firestore & log analytics
  Future<void> createUser({
    required String uid,
    required String fullName,
    required String email,
    required String role, // 'Donor' or 'Hospital'
    String? bloodType,
    String? age,
    String? weight,
    String? phone,
    required String address,
    String? gender,
    String? licenseNumber,
    String? lastDonation,
  }) async {
    final userData = {
      'fullName': fullName,
      'email': email,
      'role': role,
      'bloodType': bloodType,
      'age': age,
      'weight': weight,
      'phone': phone,
      'address': address,
      'gender': gender,
      'licenseNumber': licenseNumber,
      'lastDonation': lastDonation,
      'totalDonations': 0,
      'isAvailable': role == 'Donor' ? true : null,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('users').doc(uid).set(userData);

    // 🔥 Log registration analytics
    await _analytics.logEvent(
      name: 'new_user_registered',
      parameters: {'role': role, 'email': email},
    );
  }

  /// ✅ Fetch full user document
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  /// ✅ Fetch only role field from user document
  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['role'] as String?;
    }
    return null;
  }

  /// ✅ Create new blood request (for hospital)
  Future<void> createBloodRequest({
    required String hospitalId,
    required String bloodType,
    required int units,
    required String urgency,
    required String location,
  }) async {
    final doc = {
      'hospitalId': hospitalId,
      'bloodType': bloodType,
      'units': units,
      'urgency': urgency,
      'location': location,
      'status': 'needed',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('blood_requests').add(doc);

    // 🔥 Log blood request creation analytics
    await _analytics.logEvent(
      name: 'blood_request_created',
      parameters: {'bloodType': bloodType, 'units': units, 'urgency': urgency},
    );
  }

  /// ✅ Stream all active (needed) blood requests
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLiveRequests() {
    return _db
        .collection('blood_requests')
        .where('status', isEqualTo: 'needed')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
