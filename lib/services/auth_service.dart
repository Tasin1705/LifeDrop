import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Login failed: user not found');
      }

      // Get user role from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;
      return {
        'success': true,
        'uid': user.uid,
        'email': user.email,
        'emailVerified': true, // Always true since we don't require verification
        'role': userData['role'] ?? 'Donor',
        'message': 'Login successful!'
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for that email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      return {
        'success': false,
        'error': e.code,
        'message': message,
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register(UserModel userModel, String password) async {
    try {
      print('Starting registration process for email: ${userModel.email}');
      
      // Check if email already exists
      final methods = await _auth.fetchSignInMethodsForEmail(userModel.email);
      if (methods.isNotEmpty) {
        print('Email already exists: ${userModel.email}');
        return {
          'success': false,
          'error': 'email-already-in-use',
          'message': 'This email is already registered. Please try logging in.',
        };
      }

      print('Creating Firebase Auth user...');
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: userModel.email.toLowerCase(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        print('Failed to create user account - user is null');
        throw Exception('Failed to create user account');
      }

      print('User created successfully with UID: ${user.uid}');

      // Create user profile with UID in Firestore
      print('Creating user profile in Firestore...');
      Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': userModel.email.toLowerCase(),
        'fullName': userModel.fullName,
        'role': userModel.role,
        'phone': userModel.phone,
        'address': userModel.address,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': true // Set to true since we don't require verification
      };

      // Add role-specific fields
      if (userModel.role == 'Donor') {
        userData.addAll({
          'bloodType': userModel.bloodType,
          'age': userModel.age?.toString(),
          'gender': userModel.gender,
          'lastDonation': null,
          'isAvailable': true,
          'totalDonations': 0,
          'weight': userModel.weight ?? '',
        });
      } else if (userModel.role == 'Hospital') {
        userData.addAll({
          'licenseNumber': userModel.licenseNumber,
        });
      }
      
      print('User data prepared: ${userData.toString()}');
      await _firestore.collection('users').doc(user.uid).set(userData);
      print('User profile created in Firestore');

      return {
        'success': true,
        'message': 'Registration successful! You can now login with your credentials.',
        'uid': user.uid,
        'email': userModel.email.toLowerCase(),
        'emailVerified': true,
        'role': userModel.role
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please try logging in.';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'operation-not-allowed':
          message = 'Email/password registration is not enabled';
          break;
        case 'weak-password':
          message = 'Please choose a stronger password';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      return {
        'success': false,
        'error': e.code,
        'message': message,
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for that email';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        default:
          message = 'Failed to send reset email: ${e.message}';
      }
      return {
        'success': false,
        'error': e.code,
        'message': message,
      };
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      
      return doc.data();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}