import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationId;
  int? _resendToken;

  // Send OTP to phone number
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          if (onAutoVerify != null) {
            onAutoVerify(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The phone number format is invalid';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later';
              break;
            default:
              errorMessage = 'Verification failed: ${e.message}';
          }
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );

      return {
        'success': true,
        'message': 'OTP sent successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to send OTP: ${e.toString()}',
      };
    }
  }

  // Verify OTP code
  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    String? verificationId,
  }) async {
    try {
      final String vId = verificationId ?? _verificationId ?? '';
      if (vId.isEmpty) {
        return {
          'success': false,
          'error': 'verification-id-missing',
          'message': 'Verification ID is missing. Please request OTP again.',
        };
      }

      // Create credential
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: vId,
        smsCode: otp,
      );

      // Sign in with credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return {
          'success': false,
          'error': 'sign-in-failed',
          'message': 'Failed to sign in with OTP',
        };
      }

      // Check if user profile exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        // Existing user - return their profile
        final userData = userDoc.data()!;
        return {
          'success': true,
          'isNewUser': false,
          'uid': user.uid,
          'phoneNumber': user.phoneNumber,
          'role': userData['role'] ?? 'Donor',
          'message': 'Login successful!',
        };
      } else {
        // New user - needs to complete registration
        return {
          'success': true,
          'isNewUser': true,
          'uid': user.uid,
          'phoneNumber': user.phoneNumber,
          'message': 'Phone verified! Please complete your profile.',
        };
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-verification-code':
          message = 'Invalid OTP code. Please try again.';
          break;
        case 'session-expired':
          message = 'OTP has expired. Please request a new one.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = 'Verification failed: ${e.message}';
      }
      return {
        'success': false,
        'error': e.code,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'unknown-error',
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Link phone number to existing email account
  Future<Map<String, dynamic>> linkPhoneToExistingAccount({
    required String otp,
    String? verificationId,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'error': 'no-current-user',
          'message': 'No user is currently signed in',
        };
      }

      final String vId = verificationId ?? _verificationId ?? '';
      if (vId.isEmpty) {
        return {
          'success': false,
          'error': 'verification-id-missing',
          'message': 'Verification ID is missing',
        };
      }

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: vId,
        smsCode: otp,
      );

      // Link the phone credential to the current user
      await currentUser.linkWithCredential(credential);

      // Update user profile in Firestore with phone number
      await _firestore.collection('users').doc(currentUser.uid).update({
        'phoneNumber': currentUser.phoneNumber,
        'phoneVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Phone number linked successfully!',
        'phoneNumber': currentUser.phoneNumber,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-verification-code':
          message = 'Invalid OTP code';
          break;
        case 'credential-already-in-use':
          message = 'This phone number is already linked to another account';
          break;
        case 'provider-already-linked':
          message = 'Phone number is already linked to this account';
          break;
        default:
          message = 'Failed to link phone: ${e.message}';
      }
      return {
        'success': false,
        'error': e.code,
        'message': message,
      };
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    return await sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  // Check if phone number is already registered
  Future<Map<String, dynamic>> checkPhoneExists(String phoneNumber) async {
    try {
      // Query Firestore to check if phone number exists
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        return {
          'exists': true,
          'role': userData['role'] ?? 'Donor',
          'fullName': userData['fullName'] ?? '',
        };
      }

      return {'exists': false};
    } catch (e) {
      return {
        'exists': false,
        'error': e.toString(),
      };
    }
  }

  // Format phone number for display
  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('+91')) {
      final number = phoneNumber.substring(3);
      if (number.length == 10) {
        return '+91 ${number.substring(0, 5)} ${number.substring(5)}';
      }
    }
    return phoneNumber;
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digits
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Check if it's a valid Indian mobile number
    if (phoneNumber.startsWith('+91')) {
      return digitsOnly.length == 12 && digitsOnly.startsWith('91');
    }
    
    // Check for 10-digit Indian mobile number
    if (digitsOnly.length == 10) {
      return ['6', '7', '8', '9'].contains(digitsOnly[0]);
    }
    
    return false;
  }

  // Convert to E.164 format
  String toE164Format(String phoneNumber) {
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length == 10 && ['6', '7', '8', '9'].contains(digitsOnly[0])) {
      return '+91$digitsOnly';
    }
    
    if (digitsOnly.startsWith('91') && digitsOnly.length == 12) {
      return '+$digitsOnly';
    }
    
    return phoneNumber;
  }

  // Clean up
  void dispose() {
    _verificationId = null;
    _resendToken = null;
  }
}
