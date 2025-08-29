import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginFormDialog extends StatefulWidget {
  const LoginFormDialog({super.key});

  @override
  State<LoginFormDialog> createState() => _LoginFormDialogState();
}

class _LoginFormDialogState extends State<LoginFormDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      final user = userCredential.user;

      if (user == null) {
        setState(() => errorMessage = "Login failed: user not found.");
        return;
      }

      // Check if email is verified
      if (!user.emailVerified) {
        setState(
          () => errorMessage = "Please verify your email before logging in.",
        );

        // Show resend verification option
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email Not Verified'),
            content: const Text(
              'Please check your email and click the verification link. Would you like to resend the verification email?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await user.sendEmailVerification();
                    Navigator.pop(context);
                    setState(
                      () => errorMessage =
                          "Verification email sent! Please check your inbox.",
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    setState(
                      () => errorMessage =
                          "Failed to send verification email. Try again later.",
                    );
                  }
                },
                child: const Text('Resend'),
              ),
            ],
          ),
        );
        return;
      }

      Navigator.pop(context); // Close the dialog

      // Check user role from Firestore and navigate accordingly
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final String role = userData?['role'] ?? 'Donor';

        if (role == 'Hospital') {
          Navigator.pushReplacementNamed(context, '/hospital_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
        ); // Default to donor dashboard
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() => errorMessage = 'No account found for that email.');
      } else if (e.code == 'wrong-password') {
        setState(() => errorMessage = 'Incorrect password.');
      } else if (e.code == 'invalid-email') {
        setState(() => errorMessage = 'Invalid email format.');
      } else {
        setState(() => errorMessage = 'Login failed. Please try again.');
      }
    } catch (e) {
      setState(() => errorMessage = 'Unexpected error. Try again later.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth < 400 ? screenWidth : 400,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (screenWidth > 400)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIFE DROP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '"Every blood donor is a lifesaver"',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null)
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
