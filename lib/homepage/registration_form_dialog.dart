import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_form_dialog.dart';

class RegistrationFormDialog extends StatefulWidget {
  const RegistrationFormDialog({super.key});

  @override
  State<RegistrationFormDialog> createState() => _RegistrationFormDialogState();
}

class _RegistrationFormDialogState extends State<RegistrationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final hospitalNameController = TextEditingController();
  final locationController = TextEditingController();

  bool isDonor = true;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  String? errorMessage;
  String gender = 'Male';
  String bloodGroup = 'A+';
  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() => errorMessage = "Passwords do not match.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        setState(() => errorMessage = "Please enter a valid email address.");
        return;
      }

      // Validate password strength
      if (!RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
      ).hasMatch(password)) {
        setState(
          () => errorMessage =
              "Password must be at least 8 characters long and include both letters and numbers.",
        );
        return;
      }

      // Validate phone number format for Bangladesh
      final phone = phoneController.text.trim();
      if (!RegExp(r'^(\+880|0)(1[3-9]\d{8})$').hasMatch(phone)) {
        setState(
          () => errorMessage =
              "Please enter a valid Bangladesh phone number (e.g., +8801XXXXXXXXX or 01XXXXXXXXX)",
        );
        return;
      }

      // First create the auth user using FirebaseAuth directly
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        if (isDonor) {
          // Validate age for donors
          final age = int.tryParse(ageController.text.trim());
          if (age == null || age < 18 || age > 65) {
            setState(
              () => errorMessage = "Age must be between 18 and 65 years.",
            );
            await user.delete(); // Delete the created user if validation fails
            return;
          }

          // Create donor profile with simplified map approach
          final userData = <String, dynamic>{
            'uid': user.uid,
            'fullName': nameController.text.trim(),
            'email': email,
            'role': 'Donor',
            'bloodType': bloodGroup,
            'age': ageController.text.trim(),
            'weight': '',
            'phone': phone,
            'address': addressController.text.trim(),
            'gender': gender,
            'lastDonation': null,
            'createdAt': FieldValue.serverTimestamp(),
            'isAvailable': true,
            'totalDonations': 0,
          };

          // Add user data to Firestore directly
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userData);
        } else {
          // Create hospital profile with simplified map approach
          final userData = <String, dynamic>{
            'uid': user.uid,
            'fullName': hospitalNameController.text.trim(),
            'email': email,
            'role': 'Hospital',
            'phone': phone,
            'address': locationController.text.trim(),
            'licenseNumber': hospitalNameController.text.trim(),
            'bloodType': null,
            'age': null,
            'weight': null,
            'gender': null,
            'lastDonation': null,
            'createdAt': FieldValue.serverTimestamp(),
          };

          // Add user data to Firestore directly
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userData);
        }

        if (!mounted) return;

        Navigator.of(context).pop();

        // Show success message
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('🎉 Congratulations!'),
            content: const Text(
              'Your account has been created successfully!\n\nA verification email has been sent to your email address. Please verify your email before logging in.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close registration dialog
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => errorMessage = "Registration failed: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ❤️ Blood Quote
              const Text(
                '"You don’t have to be a doctor to save lives. Just donate blood."',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // 🩸 Custom Toggle
              Row(
                children: [
                  const Text(
                    'Register as:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey.shade300,
                    ),
                    child: Row(
                      children: [
                        _buildToggleOption('Donor', true),
                        _buildToggleOption('Hospital', false),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (isDonor) ...[
                _textField(nameController, 'Name *'),
                _textField(
                  ageController,
                  'Age *',
                  keyboardType: TextInputType.number,
                ),
                _genderSelection(),
                _textField(
                  phoneController,
                  'Phone (BD) *',
                  keyboardType: TextInputType.phone,
                ),
                _textField(addressController, 'Address *'),
                DropdownButtonFormField<String>(
                  value: bloodGroup,
                  decoration: const InputDecoration(labelText: 'Blood Group *'),
                  items: bloodGroups
                      .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                      .toList(),
                  onChanged: (val) => setState(() => bloodGroup = val!),
                ),
              ] else ...[
                _textField(hospitalNameController, 'Hospital Name *'),
                _textField(locationController, 'Location *'),
                _textField(
                  phoneController,
                  'Phone (BD) *',
                  keyboardType: TextInputType.phone,
                ),
              ],

              _textField(
                emailController,
                'Email *',
                keyboardType: TextInputType.emailAddress,
              ),
              _passwordField(
                passwordController,
                'Password *',
                showPassword,
                () {
                  setState(() => showPassword = !showPassword);
                },
              ),
              _passwordField(
                confirmPasswordController,
                'Confirm Password *',
                showConfirmPassword,
                () {
                  setState(() => showConfirmPassword = !showConfirmPassword);
                },
              ),

              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const LoginFormDialog(),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String labelText, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: labelText),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String label,
    bool visible,
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: !visible,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
        validator: (val) =>
            val == null || val.length < 6 ? 'Minimum 6 characters' : null,
      ),
    );
  }

  Widget _genderSelection() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile(
            title: const Text('Male'),
            value: 'Male',
            groupValue: gender,
            onChanged: (val) => setState(() => gender = val!),
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: const Text('Female'),
            value: 'Female',
            groupValue: gender,
            onChanged: (val) => setState(() => gender = val!),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(String label, bool value) {
    bool isSelected = isDonor == value;
    return GestureDetector(
      onTap: () => setState(() => isDonor = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
