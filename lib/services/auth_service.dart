import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'otp_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OtpService _otpService = OtpService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Verify email and password (for OTP flow)
  Future<Map<String, dynamic>> verifyEmailPassword(String email, String password) async {
    try {
      // Check for admin credentials first
      if (email.trim().toLowerCase() == 'admin@gmail.com' && password == '123456') {
        // Create/signin admin user in Firebase Auth
        UserCredential? adminCredential;
        try {
          // Try to sign in first
          adminCredential = await _auth.signInWithEmailAndPassword(
            email: 'admin@gmail.com',
            password: '123456',
          );
        } catch (e) {
          // If admin doesn't exist, create the admin account
          try {
            adminCredential = await _auth.createUserWithEmailAndPassword(
              email: 'admin@gmail.com',
              password: '123456',
            );
            
            // Create admin user document in Firestore
            await _firestore.collection('users').doc(adminCredential.user!.uid).set({
              'fullName': 'System Administrator',
              'email': 'admin@gmail.com',
              'role': 'Admin',
              'phone': '+1234567890',
              'isAdmin': true,
              'createdAt': FieldValue.serverTimestamp(),
            });
          } catch (createError) {
            return {
              'success': false,
              'error': 'admin-creation-failed',
              'message': 'Failed to create admin account: $createError',
            };
          }
        }
        
        return {
          'success': true,
          'uid': adminCredential.user!.uid,
          'email': 'admin@gmail.com',
          'role': 'Admin',
          'phoneNumber': '+1234567890',
          'isAdmin': true,
          'message': 'Admin authentication successful!'
        };
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Login failed: user not found');
      }

      // Get user role and phone from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;
      
      // Check if hospital is approved before allowing OTP
      if (userData['role'] == 'Hospital' && userData['status'] != 'approved') {
        // Sign out immediately
        await _auth.signOut();
        return {
          'success': false,
          'error': 'hospital-not-approved',
          'message': 'Your hospital account is pending admin approval. Please wait for approval.',
        };
      }
      
      // Sign out immediately after verification (will sign in after OTP)
      await _auth.signOut();
      
      return {
        'success': true,
        'uid': user.uid,
        'email': user.email,
        'role': userData['role'] ?? 'Donor',
        'phoneNumber': userData['phone'] ?? userData['phoneNumber'],
        'isAdmin': false,
        'message': 'Email and password verified!'
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
      
      // Check if hospital is approved
      if (userData['role'] == 'Hospital' && userData['status'] != 'approved') {
        return {
          'success': false,
          'error': 'hospital-not-approved',
          'message': 'Your hospital account is pending admin approval. Please wait for approval.',
        };
      }
      
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
          'status': 'pending', // Hospital needs admin approval
          'approvedAt': null,
          'approvedBy': null,
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

  // Verify phone number exists for forgot password (mock OTP flow)
  Future<Map<String, dynamic>> verifyPhoneForReset(String phoneNumber) async {
    try {
      // Check if phone number is already registered using OTP service
      final phoneCheck = await _otpService.checkPhoneExists(phoneNumber);
      
      if (!phoneCheck['exists']) {
        return {
          'success': false,
          'error': 'phone-not-registered',
          'message': 'This phone number is not registered. Please sign up first.',
        };
      }

      // Return success with user data for password reset
      return {
        'success': true,
        'phoneNumber': phoneNumber,
        'role': phoneCheck['role'] ?? 'Donor',
        'fullName': phoneCheck['fullName'] ?? 'User',
        'email': phoneCheck['email'] ?? '',
        'message': 'Phone number verified successfully!'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'verification-failed',
        'message': 'Failed to verify phone number: ${e.toString()}',
      };
    }
  }

  // Verify email exists for forgot password (mock OTP flow)
  Future<Map<String, dynamic>> verifyEmailForReset(String email) async {
    try {
      // Use Firebase Auth to check if email exists by attempting to fetch sign-in methods
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email.trim().toLowerCase());
      
      if (signInMethods.isEmpty) {
        return {
          'success': false,
          'error': 'user-not-found',
          'message': 'No account found for that email address',
        };
      }

      // Since we can't query Firestore directly due to security rules,
      // we'll use mock data for the phone number and other details
      // In a real app, you'd have a cloud function to securely retrieve this data
      return {
        'success': true,
        'email': email.trim().toLowerCase(),
        'role': 'Donor', // Default role for demo
        'phoneNumber': '+1234567890', // Mock phone number for demo
        'fullName': 'User', // Mock name for demo
        'message': 'Email verified successfully!'
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        default:
          message = 'Failed to verify email: ${e.message}';
      }
      return {
        'success': false,
        'error': e.code,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'verification-failed',
        'message': 'Failed to verify email: ${e.toString()}',
      };
    }
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

  // Sign in with phone number (OTP-based)
  Future<Map<String, dynamic>> signInWithPhone(String phoneNumber) async {
    try {
      // Check if phone number is already registered
      final phoneCheck = await _otpService.checkPhoneExists(phoneNumber);
      
      if (!phoneCheck['exists']) {
        return {
          'success': false,
          'error': 'phone-not-registered',
          'message': 'This phone number is not registered. Please sign up first.',
        };
      }

      // Return success - OTP sending will be handled by the UI
      return {
        'success': true,
        'message': 'Phone number verified. Ready to send OTP.',
        'userExists': true,
        'role': phoneCheck['role'],
        'fullName': phoneCheck['fullName'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'unknown-error',
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Complete phone registration after OTP verification
  Future<Map<String, dynamic>> completePhoneRegistration({
    required UserModel userModel,
    required String uid,
    required String phoneNumber,
  }) async {
    try {
      print('Completing phone registration for UID: $uid');
      
      // Create user profile in Firestore
      Map<String, dynamic> userData = {
        'uid': uid,
        'phoneNumber': phoneNumber,
        'fullName': userModel.fullName,
        'role': userModel.role,
        'address': userModel.address,
        'createdAt': FieldValue.serverTimestamp(),
        'phoneVerified': true,
        'emailVerified': false, // No email for phone registration
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
      
      await _firestore.collection('users').doc(uid).set(userData);
      print('Phone user profile created in Firestore');

      return {
        'success': true,
        'message': 'Registration completed successfully!',
        'uid': uid,
        'phoneNumber': phoneNumber,
        'phoneVerified': true,
        'role': userModel.role
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'registration-failed',
        'message': 'Failed to complete registration: ${e.toString()}',
      };
    }
  }

  // Link phone number to existing email account
  Future<Map<String, dynamic>> linkPhoneToAccount(String otp, String verificationId) async {
    try {
      final result = await _otpService.linkPhoneToExistingAccount(
        otp: otp,
        verificationId: verificationId,
      );
      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'link-failed',
        'message': 'Failed to link phone number: ${e.toString()}',
      };
    }
  }

  // Get OTP service instance for external use
  OtpService get otpService => _otpService;
}