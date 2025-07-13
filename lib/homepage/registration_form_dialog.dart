import 'package:flutter/material.dart';

class RegistrationFormDialog extends StatefulWidget {
  const RegistrationFormDialog({super.key});

  @override
  State<RegistrationFormDialog> createState() => _RegistrationFormDialogState();
}

class _RegistrationFormDialogState extends State<RegistrationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String? selectedGender = 'Male';
  String? selectedBloodGroup = 'A+';
  String? selectedAccountType = 'Blood Donor';

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> accountTypes = ['Blood Donor', 'Hospital'];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/dashboard');
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Image.asset('assets/lifedrop_logo.png', height: 40),
                  const SizedBox(width: 12),
                  const Text(
                    'Join LifeDrop',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'Full Name *',
                controller: fullNameController,
                hint: 'Enter your full name',
              ),
              _buildTextField(
                label: 'Phone Number *',
                controller: phoneController,
                hint: '+880 1234567890',
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Blood Type *',
                      value: selectedBloodGroup,
                      items: bloodGroups,
                      onChanged: (val) =>
                          setState(() => selectedBloodGroup = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Age *',
                      controller: ageController,
                      hint: '25',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              _buildTextField(
                label: 'Weight (kg) *',
                controller: weightController,
                hint: '70',
              ),
              _buildDropdown(
                label: 'Account Type',
                value: selectedAccountType,
                items: accountTypes,
                onChanged: (val) => setState(() => selectedAccountType = val),
              ),
              _buildTextField(
                label: 'Email Address *',
                controller: emailController,
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                label: 'Password *',
                controller: passwordController,
                hint: 'Enter password',
                obscure: true,
              ),
              _buildTextField(
                label: 'Confirm Password *',
                controller: confirmPasswordController,
                hint: 'Repeat password',
                obscure: true,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context), // Could open Login
                child: const Text(
                  'Already have an account? Sign in',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 8),
              const Text.rich(
                TextSpan(
                  text: 'By creating an account, you agree to our ',
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            validator: (value) =>
                value == null || value.isEmpty ? 'Required field' : null,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: obscure ? const Icon(Icons.visibility_off) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            validator: (value) =>
                value == null ? 'Please select an option' : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
