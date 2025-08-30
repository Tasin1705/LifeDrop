import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/blood_request/blood_request_map.dart';
import '../services/notification_service.dart';

class BloodRequestForm extends StatefulWidget {
  final String userType; // 'donor' or 'hospital'
  const BloodRequestForm({super.key, required this.userType});

  @override
  State<BloodRequestForm> createState() => _BloodRequestFormState();
}

class _BloodRequestFormState extends State<BloodRequestForm> {
  final _formKey = GlobalKey<FormState>();
  String? bloodGroup;
  String? units;
  String? contact;
  DateTime? requiredDate;
  LatLng? location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Blood Group'),
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                onChanged: (val) => bloodGroup = val,
                validator: (val) => val == null ? 'Select blood group' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Units Required'),
                keyboardType: TextInputType.number,
                onChanged: (val) => units = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter units' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contact'),
                keyboardType: TextInputType.phone,
                onChanged: (val) => contact = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter contact' : null,
              ),
              ListTile(
                title: Text(requiredDate == null
                    ? 'Select Required Date'
                    : 'Required on: ${requiredDate!.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => requiredDate = picked);
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: Text(location == null
                    ? 'Pick Location on Map'
                    : 'Selected (${location!.latitude.toStringAsFixed(2)}, ${location!.longitude.toStringAsFixed(2)})'),
                onPressed: () async {
                  final LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BloodRequestMap(
                        bloodGroup: bloodGroup ?? '',
                        units: units ?? '',
                        contact: contact ?? '',
                        requiredDate: requiredDate ?? DateTime.now(),
                        location: location ?? const LatLng(23.8103, 90.4125),
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      location = result;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Submit Request'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (location == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please pick a location on the map')),
                      );
                      return;
                    }

                    try {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const AlertDialog(
                          content: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text('Sending notifications...'),
                            ],
                          ),
                        ),
                      );

                      // Get current user info
                      final user = FirebaseAuth.instance.currentUser;
                      String requesterName = 'Unknown';
                      
                      if (user != null) {
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();
                        
                        if (userDoc.exists) {
                          requesterName = userDoc.data()?['fullName'] ?? 'Unknown';
                        }
                      }

                      // Send notifications to eligible donors
                      final notifiedUsers = await NotificationService.sendBloodRequestNotification(
                        bloodType: bloodGroup!,
                        units: units!,
                        contact: contact!,
                        requiredDate: requiredDate!,
                        latitude: location!.latitude,
                        longitude: location!.longitude,
                        requesterName: requesterName,
                        requesterType: widget.userType == 'donor' ? 'Donor' : 'Hospital',
                      );

                      // Store the blood request in Firestore
                      await FirebaseFirestore.instance.collection('blood_requests').add({
                        'bloodType': bloodGroup,
                        'units': units,
                        'contact': contact,
                        'requiredDate': Timestamp.fromDate(requiredDate!),
                        'latitude': location!.latitude,
                        'longitude': location!.longitude,
                        'requesterName': requesterName,
                        'requesterType': widget.userType == 'donor' ? 'Donor' : 'Hospital',
                        'requesterId': user?.uid,
                        'createdAt': Timestamp.now(),
                        'status': 'active',
                        'notifiedDonors': notifiedUsers,
                      });

                      // Close loading dialog
                      Navigator.pop(context);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Request submitted! ${notifiedUsers.length} eligible donors notified.'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Navigate back to dashboard
                      Navigator.pop(context);
                      
                    } catch (e) {
                      // Close loading dialog if open
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error submitting request: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
