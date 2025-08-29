import 'package:flutter/material.dart';
import 'registration_form_dialog.dart';
import 'login_form_dialog.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  void _showDonorOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join LifeDrop'),
        content: const Text('Choose an option to continue:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const RegistrationFormDialog(),
              );
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const LoginFormDialog(),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Save Lives with',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text(
            'LifeDrop',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Connect blood donors with those in need. Every drop counts in saving lives. '
            'Join our community of heroes and make a difference today.',
            style: TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showDonorOptions(context),
                icon: const Icon(Icons.favorite, color: Colors.white),
                label: const Text(
                  'Become a Donor',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showDonorOptions(context),
                icon: const Icon(Icons.warning, color: Colors.red),
                label: const Text(
                  'Emergency',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
