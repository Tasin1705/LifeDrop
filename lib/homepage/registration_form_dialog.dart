import 'package:flutter/material.dart';

class RegistrationFormDialog extends StatelessWidget {
  const RegistrationFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
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
            _buildTextField(label: 'Weight (kg) *', hint: '70'),
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

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, // Add registration logic
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
              onPressed: () {}, // Add navigation to login
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            obscureText: obscure,
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

  Widget _buildDropdown({required String label, required List<String> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: null,
            hint: const Text('Select'),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {},
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
