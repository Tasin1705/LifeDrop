import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get hospital profile
  Future<DocumentSnapshot> getHospitalProfile() async {
    if (currentUser == null) throw Exception('No authenticated user');
    return await _firestore.collection('hospitals').doc(currentUser!.uid).get();
  }

  // Update hospital profile
  Future<void> updateHospitalProfile({
    String? hospitalName,
    String? address,
    String? phoneNumber,
  }) async {
    if (currentUser == null) throw Exception('No authenticated user');

    final updates = <String, dynamic>{};
    if (hospitalName != null) updates['name'] = hospitalName;
    if (address != null) updates['address'] = address;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

    await _firestore
        .collection('hospitals')
        .doc(currentUser!.uid)
        .update(updates);
  }

  // Handle Firebase Auth errors
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return e.toString();
  }
}
