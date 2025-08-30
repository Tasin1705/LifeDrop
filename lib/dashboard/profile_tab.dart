import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String userPhone = 'Loading...';
  String userAddress = 'Loading...';
  String userBloodType = 'Loading...';
  String userAge = 'Loading...';
  String userGender = 'Loading...';
  String userRole = 'Loading...';
  List<String> userMedicalHistory = [];
  DateTime? lastDonationDate;
  bool isLoading = true;

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
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          setState(() {
            userName = userData['fullName'] as String? ?? 'Not provided';
            userEmail = userData['email'] as String? ?? user.email ?? 'Not provided';
            userPhone = userData['phone'] as String? ?? 'Not provided';
            userAddress = userData['address'] as String? ?? 'Not provided';
            userBloodType = userData['bloodType'] as String? ?? 'Not provided';
            userAge = userData['age'] as String? ?? 'Not provided';
            userGender = userData['gender'] as String? ?? 'Not provided';
            userRole = userData['role'] as String? ?? 'Not provided';
            userMedicalHistory = List<String>.from(userData['medicalHistory'] ?? []);
            lastDonationDate = userData['lastDonation'] != null 
                ? (userData['lastDonation'] as Timestamp?)?.toDate() 
                : null;
            isLoading = false;
          });
        } else {
          setState(() {
            userName = 'Not available';
            userEmail = user.email ?? 'Not available';
            userPhone = 'Not available';
            userAddress = 'Not available';
            userBloodType = 'Not available';
            userAge = 'Not available';
            userGender = 'Not available';
            userRole = 'Not available';
            userMedicalHistory = [];
            lastDonationDate = null;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
      setState(() {
        userName = 'Error loading';
        userEmail = 'Error loading';
        userPhone = 'Error loading';
        userAddress = 'Error loading';
        userBloodType = 'Error loading';
        userAge = 'Error loading';
        userGender = 'Error loading';
        userRole = 'Error loading';
        userMedicalHistory = [];
        lastDonationDate = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF0F5), // Light pink background
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header box for Donor Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Donor Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Registration Information in individual boxes
            if (isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.red))
            else
              Column(
                children: [
                  _buildInfoBox('Full Name', userName, Icons.person, isEditable: true, firestoreField: 'fullName'),
                  const SizedBox(height: 12),
                  _buildInfoBox('Email', userEmail, Icons.email),
                  const SizedBox(height: 12),
                  _buildInfoBox('Phone', userPhone, Icons.phone),
                  const SizedBox(height: 12),
                  _buildInfoBox('Address', userAddress, Icons.location_on, isEditable: true, firestoreField: 'address'),
                  const SizedBox(height: 12),
                  _buildInfoBox('Account Type', userRole, Icons.account_circle),
                  const SizedBox(height: 12),
                  if (userRole == 'Donor') ...[
                    _buildInfoBox('Blood Type', userBloodType, Icons.bloodtype),
                    const SizedBox(height: 12),
                    _buildInfoBox('Age', userAge, Icons.cake, isEditable: true, firestoreField: 'age'),
                    const SizedBox(height: 12),
                    _buildInfoBox('Gender', userGender, Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildMedicalHistoryBox(),
                  ],
                ],
              ),

          ],
        ),
      ),
    );
  }

  Future<void> _editMedicalHistory() async {
    List<String> selectedConditions = List.from(userMedicalHistory);
    
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
                final isSelected = selectedConditions.contains(condition);
                
                return CheckboxListTile(
                  title: Text(condition, style: const TextStyle(fontSize: 14)),
                  value: isSelected,
                  activeColor: Colors.red,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedConditions.add(condition);
                      } else {
                        selectedConditions.remove(condition);
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
              onPressed: () => Navigator.pop(context, selectedConditions),
              child: const Text('Save', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _updateFirestoreField('medicalHistory', result);
      _loadUserInfo(); // Reload the data
    }
  }

  Future<void> _editField(String fieldName, String currentValue, String firestoreField) async {
    final TextEditingController controller = TextEditingController(text: currentValue);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $fieldName'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: fieldName,
            border: const OutlineInputBorder(),
          ),
          keyboardType: fieldName == 'Age' ? TextInputType.number : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentValue) {
      await _updateFirestoreField(firestoreField, result);
      _loadUserInfo(); // Reload the data
    }
  }

  Future<void> _updateFirestoreField(String field, dynamic value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({field: value});
      }
    } catch (e) {
      print('Error updating $field: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update $field'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMedicalHistoryBox() {
    String displayText;
    if (userMedicalHistory.isEmpty) {
      displayText = 'No medical history recorded';
    } else if (userMedicalHistory.length == 1 && userMedicalHistory.first.contains('None')) {
      displayText = 'No medical history';
    } else {
      // Filter out "None" entries and display the actual conditions
      List<String> actualConditions = userMedicalHistory
          .where((condition) => !condition.toLowerCase().contains('none'))
          .toList();
      
      if (actualConditions.isEmpty) {
        displayText = 'No medical history';
      } else {
        displayText = actualConditions.join(', ');
      }
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.medical_services, color: Colors.red, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medical History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.red, size: 20),
              onPressed: _editMedicalHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon, {bool isEditable = false, String? firestoreField}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isEditable && firestoreField != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.red, size: 20),
                onPressed: () => _editField(label, value, firestoreField),
              ),
          ],
        ),
      ),
    );
  }
}
