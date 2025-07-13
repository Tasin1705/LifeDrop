import 'package:flutter/material.dart';

class RegistrationFormDialog extends StatelessWidget {
  const RegistrationFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset('assets/lifedrop_logo.png', height: 40),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Join LifeDrop',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Form Fields
              const SizedBox(height: 12),
              _buildTextField(label: 'Full Name *', hint: 'Enter your full name'),
              _buildTextField(
                label: 'Phone Number *',
                hint: '+880 (1865) 77-2696',
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Blood Type *',
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(label: 'Age *', hint: '25'),
                  ),
                ],
              ),
              _buildTextField(
                label: 'Weight (kg) *',
                hint: '70',
              ),
              _buildDropdown(
                label: 'Account Type',
                items: ['Blood Donor', 'Hospital'],
              ),
              _buildTextField(
                label: 'Email Address *',
                hint: 'your.email@example.com',
              ),
              _buildTextField(
                label: 'Password *',
                hint: 'Enter your password',
                obscure: true,
              ),
              _buildTextField(
                label: 'Confirm Password *',
                hint: 'Confirm your password',
                obscure: true,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {}, // Add registration logic
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {}, // Add navigation to login
                child: const Text(
                  'Already have an account? Sign in',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text.rich(
                TextSpan(
                  text: 'By creating an account, you agree to our ',
                  style: TextStyle(color: Colors.grey),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
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
    required String hint,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            obscureText: obscure,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: obscure
                  ? Icon(Icons.visibility_off, color: Colors.grey.shade400)
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String label, required List<String> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: null,
            hint: Text('Select', style: TextStyle(color: Colors.grey.shade400)),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
