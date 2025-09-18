import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notification_service.dart';

class HospitalRequestsTab extends StatefulWidget {
  const HospitalRequestsTab({super.key});

  @override
  State<HospitalRequestsTab> createState() => _HospitalRequestsTabState();
}

class _HospitalRequestsTabState extends State<HospitalRequestsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header with Create Request Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const Text(
                    'Blood Requests',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _showNewBloodRequestDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Requests List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('blood_requests')
                  .where('requesterId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bloodtype_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No blood requests yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first blood request to get started',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort the documents manually by createdAt (newest first)
                final docs = snapshot.data!.docs;
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                  return bTime.compareTo(aTime); // Descending order (newest first)
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final requiredDate = data['requiredDate'] != null 
                        ? (data['requiredDate'] as Timestamp?)?.toDate() 
                        : null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    data['bloodType'] ?? 'N/A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(data['status'] ?? 'pending'),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusText(data['status'] ?? 'pending'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Row(
                              children: [
                                const Icon(Icons.water_drop, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${data['units'] ?? 'N/A'} units required',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            if (data['urgencyLevel'] != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.priority_high, 
                                    color: _getUrgencyColor(data['urgencyLevel']), 
                                    size: 20
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Urgency: ${data['urgencyLevel']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _getUrgencyColor(data['urgencyLevel']),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],

                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Created: ${_formatDate(createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            if (requiredDate != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Required by: ${_formatFullDate(requiredDate)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    _showRequestDetails(data, doc.id);
                                  },
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: const Text('View Details'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _editRequest(data, doc.id);
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                      tooltip: 'Edit Request',
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _deleteRequest(doc.id);
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Delete Request',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showNewBloodRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => const NewBloodRequestDialog(),
    );
  }

  void _showRequestDetails(Map<String, dynamic> data, String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Blood Request - ${data['bloodType']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Blood Type:', data['bloodType'] ?? 'N/A'),
              _buildDetailRow('Units Required:', '${data['units'] ?? 'N/A'}'),
              if (data['urgencyLevel'] != null)
                _buildDetailRow('Urgency Level:', data['urgencyLevel']),
              _buildDetailRow('Contact:', data['contact'] ?? 'N/A'),
              _buildDetailRow('Status:', data['status'] ?? 'pending'),
              if (data['requiredDate'] != null)
                _buildDetailRow('Required By:', _formatFullDate((data['requiredDate'] as Timestamp?)?.toDate() ?? DateTime.now())),
              _buildDetailRow('Created:', _formatFullDate((data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now())),
              
              // Call button
              if (data['contact'] != null && data['contact'].toString().isNotEmpty && data['contact'] != 'No contact') ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(data['contact']),
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text('Call Hospital', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone dialer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching phone dialer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editRequest(Map<String, dynamic> data, String requestId) {
    showDialog(
      context: context,
      builder: (context) => EditBloodRequestDialog(
        requestId: requestId,
        currentData: data,
      ),
    );
  }

  void _deleteRequest(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this blood request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('blood_requests')
                    .doc(requestId)
                    .delete();
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Blood request deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting request: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// New Blood Request Dialog (same as in the original hospital dashboard)
class NewBloodRequestDialog extends StatefulWidget {
  const NewBloodRequestDialog({super.key});

  @override
  State<NewBloodRequestDialog> createState() => _NewBloodRequestDialogState();
}

class _NewBloodRequestDialogState extends State<NewBloodRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();
  String? _selectedBloodType;
  String? _urgencyLevel; // No default value
  DateTime? _requiredDate;
  bool _isLoading = false;
  String? _hospitalContact;
  String? _hospitalAddress;
  String? _hospitalName;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadHospitalInfo();
  }

  Future<void> _loadHospitalInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final data = userDoc.data()!;
          setState(() {
            _hospitalContact = data['phone'] ?? '';
            _hospitalAddress = data['address'] ?? '';
            _hospitalName = data['fullName'] ?? 'Unknown Hospital';
          });
        }
      }
    } catch (e) {
      print('Error loading hospital info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Blood Request'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Blood Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedBloodType,
                items: _bloodTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a blood type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitsController,
                decoration: const InputDecoration(
                  labelText: 'Units Required',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter units required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Urgency Level',
                  border: OutlineInputBorder(),
                  hintText: 'Set urgency',
                ),
                value: _urgencyLevel,
                items: const [
                  DropdownMenuItem(value: 'High', child: Text('High')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                ],
                onChanged: (value) {
                  setState(() {
                    _urgencyLevel = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select urgency level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Show hospital information (read-only)
              if (_hospitalName != null) ...[
                TextFormField(
                  initialValue: _hospitalName,
                  decoration: const InputDecoration(
                    labelText: 'Hospital/Organization Name',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
              ],
              if (_hospitalContact != null) ...[
                TextFormField(
                  initialValue: _hospitalContact,
                  decoration: const InputDecoration(
                    labelText: 'Hospital/Organization Contact',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
              ],
              if (_hospitalAddress != null) ...[
                TextFormField(
                  initialValue: _hospitalAddress,
                  decoration: const InputDecoration(
                    labelText: 'Hospital/Organization Address',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
              ],
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _requiredDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _requiredDate != null
                              ? 'Required by: ${_requiredDate!.day}/${_requiredDate!.month}/${_requiredDate!.year}'
                              : 'Select required date (optional)',
                          style: TextStyle(
                            color: _requiredDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitRequest,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Create Request', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;

      final requestData = {
        'bloodType': _selectedBloodType!,
        'units': int.parse(_unitsController.text),
        'urgencyLevel': _urgencyLevel!,
        'contact': _hospitalContact ?? 'No contact',
        'requesterId': user.uid,
        'requesterName': _hospitalName ?? 'Unknown Hospital',
        'requesterType': 'Hospital',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'hospitalAddress': _hospitalAddress,
        if (_requiredDate != null) 'requiredDate': Timestamp.fromDate(_requiredDate!),
      };

      // Create the blood request
      final docRef = await FirebaseFirestore.instance
          .collection('blood_requests')
          .add(requestData);

      // Send notifications to eligible donors
      await NotificationService.sendBloodRequestNotification(
        bloodType: _selectedBloodType!,
        units: _unitsController.text,
        contact: _hospitalContact ?? 'No contact',
        requesterName: _hospitalName ?? 'Unknown Hospital',
        requesterType: 'Hospital',
        requiredDate: _requiredDate ?? DateTime.now().add(const Duration(days: 1)),
        latitude: 0.0, // TODO: Get actual hospital location
        longitude: 0.0, // TODO: Get actual hospital location
        requestId: docRef.id,
        requesterId: user.uid,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blood request created and notifications sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }
}

// Edit Blood Request Dialog
class EditBloodRequestDialog extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> currentData;

  const EditBloodRequestDialog({
    super.key,
    required this.requestId,
    required this.currentData,
  });

  @override
  State<EditBloodRequestDialog> createState() => _EditBloodRequestDialogState();
}

class _EditBloodRequestDialogState extends State<EditBloodRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();
  String? _selectedBloodType;
  String? _urgencyLevel;
  DateTime? _requiredDate;
  bool _isLoading = false;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    _selectedBloodType = widget.currentData['bloodType'];
    _unitsController.text = widget.currentData['units']?.toString() ?? '';
    _urgencyLevel = widget.currentData['urgencyLevel'];
    
    if (widget.currentData['requiredDate'] != null) {
      _requiredDate = (widget.currentData['requiredDate'] as Timestamp).toDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Blood Request'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Blood Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedBloodType,
                items: _bloodTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a blood type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitsController,
                decoration: const InputDecoration(
                  labelText: 'Units Required',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter units required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Urgency Level',
                  border: OutlineInputBorder(),
                  hintText: 'Set urgency',
                ),
                value: _urgencyLevel,
                items: const [
                  DropdownMenuItem(value: 'High', child: Text('High')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                ],
                onChanged: (value) {
                  setState(() {
                    _urgencyLevel = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select urgency level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _requiredDate ?? DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _requiredDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _requiredDate != null
                              ? 'Required by: ${_requiredDate!.day}/${_requiredDate!.month}/${_requiredDate!.year}'
                              : 'Select required date (optional)',
                          style: TextStyle(
                            color: _requiredDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateRequest,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Update Request', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _updateRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updateData = <String, dynamic>{
        'bloodType': _selectedBloodType!,
        'units': int.parse(_unitsController.text),
        'urgencyLevel': _urgencyLevel!,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_requiredDate != null) {
        updateData['requiredDate'] = Timestamp.fromDate(_requiredDate!);
      }

      // Update the blood request
      await FirebaseFirestore.instance
          .collection('blood_requests')
          .doc(widget.requestId)
          .update(updateData);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blood request updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }
}
