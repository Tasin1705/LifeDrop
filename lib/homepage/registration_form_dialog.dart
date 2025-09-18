import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_form_dialog.dart';

class RegistrationFormDialog extends StatefulWidget {
  const RegistrationFormDialog({super.key});

  @override
  State<RegistrationFormDialog> createState() => _RegistrationFormDialogState();
}

class _RegistrationFormDialogState extends State<RegistrationFormDialog> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final hospitalNameController = TextEditingController();
  final hospitalLicenseController = TextEditingController();
  final locationController = TextEditingController();

  bool isDonor = true;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  String? errorMessage;
  String gender = 'Male';
  String? bloodGroup; // Changed to nullable to show placeholder
  List<String> selectedMedicalHistory = [];
  bool _useGoogleMaps = false; // Toggle between manual location and Google Maps
  double? _selectedLatitude;
  double? _selectedLongitude;
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
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    hospitalNameController.dispose();
    hospitalLicenseController.dispose();
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

    final email = emailController.text.trim().toLowerCase();
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
      if (!_validateInputs(email, password, phone)) {
        setState(() => isLoading = false);
        return;
      }

      if (!_validateCommonFields()) {
        setState(() => isLoading = false);
        return;
      }

      final userModel = _createUserModel(email, phone);

      final result = await _authService.register(userModel, password);

      if (!result['success']) {
        setState(() => errorMessage = result['message']);
        return;
      }

      if (!mounted) return;

      // Close registration dialog only - no navigation
      Navigator.of(context).pop();

    } catch (e) {
      setState(() => errorMessage = "Registration failed: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validateCommonFields() {
    if (isDonor) {
      final age = int.tryParse(ageController.text.trim());
      if (age == null || age < 18 || age > 65) {
        setState(() {
          errorMessage = "Age must be between 18 and 65 years.";
        });
        return false;
      }

      if (selectedMedicalHistory.isEmpty) {
        setState(() {
          errorMessage = "Please select at least one medical condition or 'None' if you have no medical history.";
        });
        return false;
      }

      if (bloodGroup == null) {
        setState(() {
          errorMessage = "Please select your blood group.";
        });
        return false;
      }
    } else {
      final licenseNumber = hospitalLicenseController.text.trim();
      if (licenseNumber.isEmpty) {
        setState(() {
          errorMessage = "Please enter the hospital license number.";
        });
        return false;
      }
    }

    return true;
  }

  UserModel _createUserModel(String email, String phone) {
    return UserModel(
      uid: '',
      fullName: isDonor ? nameController.text.trim() : hospitalNameController.text.trim(),
      email: email,
      role: isDonor ? 'Donor' : 'Hospital',
      phone: phone,
      address: isDonor ? addressController.text.trim() : locationController.text.trim(),
      createdAt: DateTime.now(),
      bloodType: isDonor ? bloodGroup : null,
      age: isDonor ? int.tryParse(ageController.text.trim()) : null,
      gender: isDonor ? gender : null,
      lastDonation: null,
      isAvailable: isDonor ? true : null,
      totalDonations: isDonor ? 0 : null,
      weight: isDonor ? '' : null,
      medicalHistory: isDonor ? selectedMedicalHistory : null,
      licenseNumber: isDonor ? null : hospitalLicenseController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Background floating orbs
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Positioned(
                top: 50 + _floatAnimation.value,
                left: 30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.3),
                        Colors.pink.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 100,
                right: 20,
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.2),
                          Colors.orange.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Another floating orb
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Positioned(
                top: 200 - _floatAnimation.value,
                right: 40,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.4),
                        Colors.deepOrange.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Main glassmorphism container
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with glassmorphism effect
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Join the Life-Saving Community',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '"You don\'t have to be a doctor to save lives. Just donate blood."',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.red,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Role selection with glassmorphism
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Register as:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.2),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildToggleOption('Donor', true),
                                    _buildToggleOption('Organization', false),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form fields container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
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
                              _buildUnifiedLocationSelectionField('Address *'),
                              _buildGlassmorphismDropdown(),
                              _buildMedicalHistoryField(),
                            ] else ...[
                              _textField(hospitalNameController, 'Organization Name *'),
                              _textField(hospitalLicenseController, 'License Number *'),
                              _buildUnifiedLocationSelectionField('Organization Location *'),
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
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.red.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Register button with glassmorphism
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.withOpacity(0.8),
                              Colors.red.withOpacity(0.9),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login link with glassmorphism
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(color: Colors.black87),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
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
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _selectBloodGroup,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bloodGroup ?? 'Select blood group *',
                style: TextStyle(
                  color: bloodGroup != null ? Colors.black87 : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[600],
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
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: selectedMedicalHistory.isEmpty 
                  ? Colors.red.withOpacity(0.6) 
                  : Colors.white.withOpacity(0.4),
              width: selectedMedicalHistory.isEmpty ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedMedicalHistory.isEmpty ? Colors.red : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down, 
                color: Colors.black54,
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: Colors.black54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: !visible,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
              ),
              onPressed: toggle,
            ),
          ),
          validator: (val) =>
              val == null || val.length < 6 ? 'Minimum 6 characters' : null,
        ),
      ),
    );
  }

  Widget _genderSelection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile(
              title: const Text(
                'Male', 
                style: TextStyle(color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              value: 'Male',
              groupValue: gender,
              activeColor: Colors.red,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => gender = val!),
            ),
          ),
          Expanded(
            child: RadioListTile(
              title: const Text(
                'Female', 
                style: TextStyle(color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              value: 'Female',
              groupValue: gender,
              activeColor: Colors.red,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => gender = val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool value) {
    bool isSelected = isDonor == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isDonor = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedLocationSelectionField(String labelText) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location type toggle
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _useGoogleMaps = false;
                      _selectedLatitude = null;
                      _selectedLongitude = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: !_useGoogleMaps
                            ? const Color(0xFFE53E3E).withOpacity(0.8)
                            : Colors.transparent,
                      ),
                      child: Text(
                        'Manual Input',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: !_useGoogleMaps ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _useGoogleMaps = true;
                      // Don't auto-open map, just switch the toggle
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: _useGoogleMaps
                            ? const Color(0xFFE53E3E).withOpacity(0.8)
                            : Colors.transparent,
                      ),
                      child: Text(
                        'Google Maps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _useGoogleMaps ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Location input field
          if (!_useGoogleMaps)
            _textField(
              isDonor ? addressController : locationController, 
              labelText,
            )
          else
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: _selectedLatitude != null 
                        ? Colors.green 
                        : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedLatitude != null && _selectedLongitude != null
                          ? 'Current location selected'
                          : 'Tap to select current location',
                      style: TextStyle(
                        color: _selectedLatitude != null 
                            ? Colors.black87 
                            : Colors.grey[600],
                        fontSize: 16,
                        fontWeight: _selectedLatitude != null 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openGoogleMapsPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFE53E3E).withOpacity(0.8),
                      ),
                      child: const Text(
                        'Select',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMapsPicker() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showLocationPermissionDialog();
        return;
      }

      // Show loading indicator while getting location
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
          ),
        ),
      );

      // Get current location
      Position? currentPosition;
      try {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        
        // Close loading indicator
        if (mounted) Navigator.of(context).pop();
        
        // Automatically set the current location as selected
        setState(() {
          _selectedLatitude = currentPosition!.latitude;
          _selectedLongitude = currentPosition.longitude;
          _useGoogleMaps = true;
        });

      } catch (e) {
        // Close loading indicator
        if (mounted) Navigator.of(context).pop();
        
        // If we can't get current location, use default (Dhaka, Bangladesh)
        currentPosition = Position(
          latitude: 23.8103,
          longitude: 90.4125,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        
        // Show info that we're using default location
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not get current location. Using default location.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Open the map picker dialog with current location pre-selected
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _GoogleMapPickerDialog(
          initialPosition: LatLng(currentPosition!.latitude, currentPosition.longitude),
        ),
      );

      if (result != null) {
        setState(() {
          _selectedLatitude = result['latitude'];
          _selectedLongitude = result['longitude'];
        });

        // Update the appropriate text controller with the address from dialog
        final controller = isDonor ? addressController : locationController;
        
        if (result['address'] != null && result['address'].toString().isNotEmpty) {
          controller.text = result['address'];
        } else {
          // Fallback: Get address from coordinates if not provided
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              _selectedLatitude!,
              _selectedLongitude!,
            );
            
            if (placemarks.isNotEmpty) {
              final placemark = placemarks.first;
              
              // Build a comprehensive address string
              List<String> addressParts = [];
              
              if (placemark.name != null && placemark.name!.isNotEmpty) {
                addressParts.add(placemark.name!);
              }
              if (placemark.street != null && placemark.street!.isNotEmpty) {
                addressParts.add(placemark.street!);
              }
              if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
                addressParts.add(placemark.subLocality!);
              }
              if (placemark.locality != null && placemark.locality!.isNotEmpty) {
                addressParts.add(placemark.locality!);
              }
              if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
                addressParts.add(placemark.administrativeArea!);
              }
              if (placemark.country != null && placemark.country!.isNotEmpty) {
                addressParts.add(placemark.country!);
              }
              
              // Remove duplicates and empty parts
              addressParts = addressParts.toSet().where((part) => part.trim().isNotEmpty).toList();
              
              final fullAddress = addressParts.join(', ');
              controller.text = fullAddress.isNotEmpty ? fullAddress : 'Location: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}';
            } else {
              controller.text = 'Location: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}';
            }
          } catch (e) {
            controller.text = 'Location: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}';
          }
        }
      }
    } catch (e) {
      // Close loading indicator if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showErrorDialog('Error opening map: ${e.toString()}');
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'Location permission is required to use Google Maps for location selection. '
          'Please grant location permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _selectBloodGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Blood Group'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bloodGroups.length,
            itemBuilder: (context, index) {
              final bloodType = bloodGroups[index];
              return ListTile(
                title: Text(
                  bloodType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE53E3E).withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      bloodType,
                      style: const TextStyle(
                        color: Color(0xFFE53E3E),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    bloodGroup = bloodType;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _GoogleMapPickerDialog extends StatefulWidget {
  final LatLng initialPosition;

  const _GoogleMapPickerDialog({
    required this.initialPosition,
  });

  @override
  State<_GoogleMapPickerDialog> createState() => _GoogleMapPickerDialogState();
}

class _GoogleMapPickerDialogState extends State<_GoogleMapPickerDialog> {
  late GoogleMapController mapController;
  LatLng? selectedPosition;
  Set<Marker> markers = {};
  String selectedAddress = 'Getting address...';
  bool isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    selectedPosition = widget.initialPosition;
    _updateMarker(widget.initialPosition);
    // Automatically select the current location when the dialog opens
    _setCurrentLocationAsSelected();
  }

  void _setCurrentLocationAsSelected() {
    // Set the initial position as the selected location
    selectedPosition = widget.initialPosition;
  }

  void _updateMarker(LatLng position) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            _updateMarker(newPosition);
            selectedPosition = newPosition;
          },
        ),
      );
      selectedPosition = position;
    });
    
    // Fetch address for the selected position
    _getAddressFromPosition(position);
  }

  Future<void> _getAddressFromPosition(LatLng position) async {
    setState(() {
      isLoadingAddress = true;
      selectedAddress = 'Getting address...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // Build a comprehensive address string
        List<String> addressParts = [];
        
        if (placemark.name != null && placemark.name!.isNotEmpty) {
          addressParts.add(placemark.name!);
        }
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          addressParts.add(placemark.subLocality!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }
        
        // Remove duplicates and empty parts
        addressParts = addressParts.toSet().where((part) => part.trim().isNotEmpty).toList();
        
        final fullAddress = addressParts.join(', ');
        
        setState(() {
          selectedAddress = fullAddress.isNotEmpty 
              ? fullAddress 
              : 'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          isLoadingAddress = false;
        });
      } else {
        setState(() {
          selectedAddress = 'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = 'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Select Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Map
            Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: widget.initialPosition,
                  zoom: 16, // Closer zoom for better precision
                ),
                markers: markers,
                onTap: (LatLng position) {
                  _updateMarker(position);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              ),
            ),
            // Instructions and actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Address preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Selected Address:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (isLoadingAddress)
                          Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Getting address...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            selectedAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap on the map or drag the marker to select your location',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Use Current Location button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _updateMarker(widget.initialPosition);
                        mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(widget.initialPosition, 16),
                        );
                      },
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Use Current Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedPosition != null
                              ? () {
                                  Navigator.of(context).pop({
                                    'latitude': selectedPosition!.latitude,
                                    'longitude': selectedPosition!.longitude,
                                    'address': selectedAddress,
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53E3E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Select Location'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}