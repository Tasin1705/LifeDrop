import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalDonorsTab extends StatefulWidget {
  const HospitalDonorsTab({super.key});

  @override
  State<HospitalDonorsTab> createState() => _HospitalDonorsTabState();
}

class _HospitalDonorsTabState extends State<HospitalDonorsTab> {
  String _searchQuery = '';
  String? _selectedBloodType;
  String _searchType = 'name'; // 'name', 'phone', 'history'
  final List<String> _bloodTypes = ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header and Filters
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registered Donors',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    // Search Field
                    TextField(
                      decoration: InputDecoration(
                        hintText: _getSearchHint(),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    // Filters Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Search Type',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            value: _searchType,
                            items: [
                              const DropdownMenuItem(
                                value: 'name',
                                child: Text('Name', style: TextStyle(fontSize: 14)),
                              ),
                              const DropdownMenuItem(
                                value: 'phone',
                                child: Text('Phone', style: TextStyle(fontSize: 14)),
                              ),
                              const DropdownMenuItem(
                                value: 'history',
                                child: Text('History', style: TextStyle(fontSize: 14)),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _searchType = value ?? 'name';
                                _searchQuery = ''; // Clear search when switching types
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Blood Group',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            value: _selectedBloodType,
                            items: _bloodTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBloodType = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Donors List
          Expanded(
            child: _searchType == 'history' 
                ? _buildDonationHistoryView()
                : _buildDonorsListView(),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildDonorsStream() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'donor');

    if (_selectedBloodType != null && _selectedBloodType != 'All') {
      query = query.where('bloodType', isEqualTo: _selectedBloodType);
    }

    return query.snapshots();
  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  int _calculateAge(dynamic dateOfBirth) {
    if (dateOfBirth == null) return 0;
    
    DateTime birthDate;
    if (dateOfBirth is Timestamp) {
      birthDate = dateOfBirth.toDate();
    } else if (dateOfBirth is String) {
      try {
        birthDate = DateTime.parse(dateOfBirth);
      } catch (e) {
        return 0;
      }
    } else {
      return 0;
    }
    
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatLastDonation(dynamic lastDonation) {
    if (lastDonation == null) return 'Never';
    
    DateTime donationDate;
    if (lastDonation is Timestamp) {
      donationDate = lastDonation.toDate();
    } else if (lastDonation is String) {
      try {
        donationDate = DateTime.parse(lastDonation);
      } catch (e) {
        return 'Unknown';
      }
    } else {
      return 'Unknown';
    }
    
    final now = DateTime.now();
    final difference = now.difference(donationDate);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return 'Today';
    }
  }

  bool _isEligibleToDonate(dynamic lastDonation) {
    if (lastDonation == null) return true; // Never donated, eligible
    
    DateTime donationDate;
    if (lastDonation is Timestamp) {
      donationDate = lastDonation.toDate();
    } else if (lastDonation is String) {
      try {
        donationDate = DateTime.parse(lastDonation);
      } catch (e) {
        return true; // If we can't parse, assume eligible
      }
    } else {
      return true;
    }
    
    final now = DateTime.now();
    final daysSinceLastDonation = now.difference(donationDate).inDays;
    return daysSinceLastDonation >= 90; // 3 months = 90 days
  }

  int _getDaysUntilEligible(dynamic lastDonation) {
    if (lastDonation == null) return 0;
    
    DateTime donationDate;
    if (lastDonation is Timestamp) {
      donationDate = lastDonation.toDate();
    } else if (lastDonation is String) {
      try {
        donationDate = DateTime.parse(lastDonation);
      } catch (e) {
        return 0;
      }
    } else {
      return 0;
    }
    
    final now = DateTime.now();
    final daysSinceLastDonation = now.difference(donationDate).inDays;
    return daysSinceLastDonation >= 90 ? 0 : 90 - daysSinceLastDonation;
  }

  void _showDonorDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['fullName'] ?? 'Donor Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email:', data['email'] ?? 'N/A'),
              _buildDetailRow('Phone:', data['phone'] ?? 'N/A'),
              _buildDetailRow('Blood Type:', data['bloodType'] ?? 'N/A'),
              _buildDetailRow('Age:', '${_calculateAge(data['dateOfBirth'])} years'),
              _buildDetailRow('Gender:', data['gender'] ?? 'N/A'),
              _buildDetailRow('Address:', '${data['address'] ?? ''}, ${data['city'] ?? ''}, ${data['state'] ?? ''}'),
              _buildDetailRow('Last Donation:', _formatLastDonation(data['lastDonation'])),
              _buildDetailRow('Eligibility:', _isEligibleToDonate(data['lastDonation']) ? 'Eligible' : 'Not Eligible'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (data['phone'] != null && data['phone'].toString().isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _callDonor(data['phone']);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Call Donor', style: TextStyle(color: Colors.white)),
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

  void _callDonor(String phoneNumber) {
    // TODO: Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phoneNumber...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: () {},
        ),
      ),
    );
  }

  String _getSearchHint() {
    switch (_searchType) {
      case 'phone':
        return 'Search by phone number...';
      case 'history':
        return 'Search donation history...';
      default:
        return 'Search donors by name...';
    }
  }

  Widget _buildDonorsListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildDonorsStream(),
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
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No donors found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final donors = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          
          if (_searchType == 'phone') {
            final phone = (data['phone'] ?? '').toString().toLowerCase();
            return phone.contains(_searchQuery.toLowerCase());
          } else {
            final name = (data['fullName'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: donors.length,
          itemBuilder: (context, index) {
            final doc = donors[index];
            final data = doc.data() as Map<String, dynamic>;
            
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
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red.shade100,
                          child: Text(
                            _getInitials(data['fullName'] ?? 'Unknown'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['fullName'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['email'] ?? 'No email',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoTile(
                            Icons.phone,
                            'Phone',
                            data['phone'] ?? 'No phone',
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoTile(
                            Icons.cake,
                            'Age',
                            '${_calculateAge(data['dateOfBirth'])} years',
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoTile(
                            Icons.location_on,
                            'Location',
                            '${data['city'] ?? 'Unknown'}, ${data['state'] ?? 'Unknown'}',
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoTile(
                            Icons.schedule,
                            'Last Donation',
                            _formatLastDonation(data['lastDonation']),
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Eligibility Status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isEligibleToDonate(data['lastDonation']) 
                            ? Colors.green.shade50 
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isEligibleToDonate(data['lastDonation']) 
                              ? Colors.green 
                              : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isEligibleToDonate(data['lastDonation']) 
                                ? Icons.check_circle 
                                : Icons.schedule,
                            color: _isEligibleToDonate(data['lastDonation']) 
                                ? Colors.green 
                                : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEligibleToDonate(data['lastDonation'])
                                ? 'Eligible to donate'
                                : 'Not eligible yet (${_getDaysUntilEligible(data['lastDonation'])} days remaining)',
                            style: TextStyle(
                              color: _isEligibleToDonate(data['lastDonation']) 
                                  ? Colors.green.shade700 
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            _showDonorDetails(data);
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View Details'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                        if (data['phone'] != null && data['phone'].toString().isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              _callDonor(data['phone']);
                            },
                            icon: const Icon(Icons.phone, size: 16),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
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
    );
  }

  Widget _buildDonationHistoryView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildDonationHistoryStream(),
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
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No donation history found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final donations = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          
          if (_searchQuery.isNotEmpty) {
            final donorName = (data['donorName'] ?? '').toString().toLowerCase();
            final donorContact = (data['donorContact'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return donorName.contains(query) || donorContact.contains(query);
          }
          
          return true;
        }).toList();

        // Sort by donation date (newest first)
        donations.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = (aData['donationDate'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bTime = (bData['donationDate'] as Timestamp?)?.toDate() ?? DateTime.now();
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: donations.length,
          itemBuilder: (context, index) {
            final doc = donations[index];
            final data = doc.data() as Map<String, dynamic>;
            final donationDate = (data['donationDate'] as Timestamp?)?.toDate() ?? DateTime.now();
            
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
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            Icons.bloodtype,
                            color: Colors.green.shade700,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['donorName'] ?? 'Unknown Donor',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Donated on ${_formatDate(donationDate)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoTile(
                            Icons.water_drop,
                            'Units',
                            data['units'] ?? 'Unknown',
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoTile(
                            Icons.phone,
                            'Contact',
                            data['donorContact'] ?? 'No contact',
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoTile(
                            Icons.local_hospital,
                            'Hospital',
                            data['hospitalName'] ?? 'Unknown Hospital',
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoTile(
                            Icons.check_circle,
                            'Status',
                            data['status'] ?? 'Unknown',
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Donation ID: ${doc.id.substring(0, 8)}...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (data['donorContact'] != null && data['donorContact'].toString().isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              _callDonor(data['donorContact']);
                            },
                            icon: const Icon(Icons.phone, size: 16),
                            label: const Text('Call Donor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
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
    );
  }

  Stream<QuerySnapshot> _buildDonationHistoryStream() {
    Query query = FirebaseFirestore.instance
        .collection('donation_history')
        .where('status', isEqualTo: 'completed');

    if (_selectedBloodType != null && _selectedBloodType != 'All') {
      query = query.where('bloodType', isEqualTo: _selectedBloodType);
    }

    return query.snapshots();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
