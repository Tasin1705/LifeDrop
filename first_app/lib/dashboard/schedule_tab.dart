import 'package:flutter/material.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Schedule Appointment',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // 🔁 Button aligned to left
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DonorFormDialog(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'New Appointment',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 🩸 Appointment Cards
        const _ScheduleCard(
          center: 'City Blood Center',
          date: '2024-01-20 at 10:00 AM',
          location: '123 Health St, Downtown',
          status: 'confirmed',
        ),
        const SizedBox(height: 12),
        const _ScheduleCard(
          center: 'Memorial Hospital',
          date: '2024-03-15 at 2:00 PM',
          location: '456 Medical Ave, Midtown',
          status: 'pending',
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String center;
  final String date;
  final String location;
  final String status;

  const _ScheduleCard({
    required this.center,
    required this.date,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor = Colors.grey.shade200;
    Color textColor = Colors.black;
    Icon statusIcon = const Icon(
      Icons.help_outline,
      size: 18,
      color: Colors.black45,
    );

    if (status == 'confirmed') {
      badgeColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      statusIcon = const Icon(
        Icons.check_circle,
        size: 18,
        color: Colors.green,
      );
    } else if (status == 'pending') {
      badgeColor = Colors.yellow.shade100;
      textColor = Colors.orange.shade800;
      statusIcon = const Icon(
        Icons.hourglass_bottom,
        size: 18,
        color: Colors.orange,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(date),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📍 Location
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Flexible(child: Text(location)),
                  ],
                ),
              ),

              // ✅ Status with icon
              Row(
                children: [
                  statusIcon,
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Add this new widget below your existing code
class DonorFormDialog extends StatefulWidget {
  const DonorFormDialog({super.key});

  @override
  State<DonorFormDialog> createState() => _DonorFormDialogState();
}

class _DonorFormDialogState extends State<DonorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String bloodGroup = '';
  String contact = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Donor's Information"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (val) => setState(() => name = val),
                validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Blood Group'),
                onChanged: (val) => setState(() => bloodGroup = val),
                validator: (val) => val == null || val.isEmpty ? 'Enter blood group' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contact'),
                keyboardType: TextInputType.phone,
                onChanged: (val) => setState(() => contact = val),
                validator: (val) => val == null || val.isEmpty ? 'Enter contact' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // You can handle the form submission here
              Navigator.of(context).pop();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
