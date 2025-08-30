import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
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
  List<String> selectedMedicalHistory = [];
  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  final List<String> medicalConditions = [
    'None (No medical history)',
    'HIV/AIDS',
    'Hepatitis B',
    'Hepatitis C',
    'Malaria',
    'Tuberculosis (TB)',
    'Syphilis',
    'Chagas disease',
    'West Nile Virus',
    'Zika Virus',
    'Dengue',
    'Human T-lymphotropic virus (HTLV)',
    'Creutzfeldt-Jakob disease (CJD)',
    'Chikungunya',
    'Leprosy',
    'Ebola Virus Disease',
    'Rabies',
    'Yellow Fever',
    'Measles',
    'Sickle Cell Disease',
    'Thalassemia',
    'Hemophilia',
    'Autoimmune Disorders',
    'Cancer',
    'Blood Clotting Disorders',
    'Heart Disease',
    'Renal Failure or Kidney Disease',
    'Diabetes',
    'Asthma',
    'Chronic Fatigue Syndrome',
    'Epilepsy or Seizure Disorders',
    'Hypertension (High Blood Pressure)',
    'Pregnancy',
  ];

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    hospitalNameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  bool _validateInputs(String email, String password, String phone) {
    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => errorMessage = "Please enter a valid email address.");
      return false;
    }

    // Validate password strength
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password)) {
      setState(() => errorMessage =
          "Password must be at least 8 characters long and include both letters and numbers.");
      return false;
    }

    // Validate phone number format for Bangladesh
    if (!RegExp(r'^(\+880|0)(1[3-9]\d{8})$').hasMatch(phone)) {
      setState(() => errorMessage =
          "Please enter a valid Bangladesh phone number (e.g., +8801XXXXXXXXX or 01XXXXXXXXX)");
      return false;
    }

    return true;
  }

  Future<void> _selectMedicalHistory() async {
    List<String> tempSelectedConditions = List.from(selectedMedicalHistory);
    
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Medical History'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: medicalConditions.length,
              itemBuilder: (context, index) {
                final condition = medicalConditions[index];
                final isSelected = tempSelectedConditions.contains(condition);
                
                return CheckboxListTile(
                  title: Text(condition, style: const TextStyle(fontSize: 14)),
                  value: isSelected,
                  activeColor: Colors.red,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        tempSelectedConditions.add(condition);
                      } else {
                        tempSelectedConditions.remove(condition);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempSelectedConditions),
              child: const Text('Save', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedMedicalHistory = result;
      });
    }
  }

  final AuthService _authService = AuthService();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim().toLowerCase(); // Convert to lowercase
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final phone = phoneController.text.trim();

    if (password != confirmPassword) {
      setState(() => errorMessage = "Passwords do not match.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Basic validations
      if (!_validateInputs(email, password, phone)) {
        setState(() => isLoading = false);
        return;
      }

      if (isDonor) {
        final age = int.tryParse(ageController.text.trim());
        if (age == null || age < 18 || age > 65) {
          setState(() {
            errorMessage = "Age must be between 18 and 65 years.";
            isLoading = false;
          });
          return;
        }

        // Validate medical history selection
        if (selectedMedicalHistory.isEmpty) {
          setState(() {
            errorMessage = "Please select at least one medical condition or 'None' if you have no medical history.";
            isLoading = false;
          });
          return;
        }
      }

      // Create user model
      final userModel = UserModel(
        uid: '',  // This will be set by Firebase Auth after registration
        fullName: isDonor ? nameController.text.trim() : hospitalNameController.text.trim(),
        email: email,
        role: isDonor ? 'Donor' : 'Hospital',
        phone: phone,
        address: isDonor ? addressController.text.trim() : locationController.text.trim(),
        createdAt: DateTime.now(),
        // Donor specific fields
        bloodType: isDonor ? bloodGroup : null,
        age: isDonor ? int.tryParse(ageController.text.trim()) : null,
        gender: isDonor ? gender : null,
        lastDonation: null,
        isAvailable: isDonor ? true : null,
        totalDonations: isDonor ? 0 : null,
        weight: isDonor ? '' : null,
        medicalHistory: isDonor ? selectedMedicalHistory : null,
        // Hospital specific fields
        licenseNumber: isDonor ? null : hospitalNameController.text.trim(),
      );

      final result = await _authService.register(userModel, password);

      if (!result['success']) {
        setState(() => errorMessage = result['message']);
        return;
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      // Show success message for 3 seconds
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('🎉 Congratulations!'),
          content: const Text(
            'Your account has been created successfully!\n\nYou can now login with your email and password.',
          ),
          // No actions - dialog will auto-dismiss
        ),
      );

      // Auto-dismiss after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Close success dialog
          Navigator.of(context).pop(); // Close registration dialog
        }
      });
    } catch (e) {
      print('Error during registration:');
      print(e.toString());
      setState(() => errorMessage = 'Registration failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
                _buildMedicalHistoryField(),
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

  Widget _buildMedicalHistoryField() {
    String displayText = selectedMedicalHistory.isEmpty 
        ? 'Select Medical History *' 
        : '${selectedMedicalHistory.length} condition(s) selected';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _selectMedicalHistory,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedMedicalHistory.isEmpty ? Colors.red : Colors.grey,
              width: selectedMedicalHistory.isEmpty ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedMedicalHistory.isEmpty ? Colors.red : Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
