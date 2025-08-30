import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;  // Make uid optional for registration
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String address;
  final DateTime createdAt;

  // Donor-specific fields
  final String? bloodType;
  final int? age;
  final String? gender;
  final DateTime? lastDonation;
  final bool? isAvailable;
  final int? totalDonations;
  final String? weight;
  final List<String>? medicalHistory;

  // Hospital-specific fields
  final String? licenseNumber;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
    required this.createdAt,
    this.bloodType,
    this.age,
    this.gender,
    this.lastDonation,
    this.isAvailable,
    this.totalDonations,
    this.weight,
    this.medicalHistory,
    this.licenseNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString(),
      fullName: map['fullName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Donor',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()
          : DateTime.now(),
      bloodType: map['bloodType']?.toString(),
      age: map['age'] != null ? int.tryParse(map['age'].toString()) : null,
      gender: map['gender']?.toString(),
      lastDonation: map['lastDonation'] != null 
          ? (map['lastDonation'] as Timestamp?)?.toDate() 
          : null,
      isAvailable: map['isAvailable'] as bool? ?? true,
      totalDonations: map['totalDonations'] != null 
          ? int.tryParse(map['totalDonations'].toString()) ?? 0
          : 0,
      weight: map['weight']?.toString(),
      medicalHistory: map['medicalHistory'] != null 
          ? List<String>.from(map['medicalHistory'])
          : null,
      licenseNumber: map['licenseNumber']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'fullName': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
    
    if (uid != null) {
      data['uid'] = uid;
    }

    if (role == 'Donor') {
      data.addAll({
        'bloodType': bloodType,
        'age': age?.toString(),
        'gender': gender,
        'lastDonation': lastDonation != null ? Timestamp.fromDate(lastDonation!) : null,
        'isAvailable': isAvailable ?? true,
        'totalDonations': totalDonations ?? 0,
        'weight': weight ?? '',
        'medicalHistory': medicalHistory ?? [],
      });
    } else if (role == 'Hospital') {
      data.addAll({
        'licenseNumber': licenseNumber,
      });
    }

    return data;
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? role,
    String? phone,
    String? address,
    DateTime? createdAt,
    String? bloodType,
    int? age,
    String? gender,
    DateTime? lastDonation,
    bool? isAvailable,
    int? totalDonations,
    String? weight,
    List<String>? medicalHistory,
    String? licenseNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      bloodType: bloodType ?? this.bloodType,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      lastDonation: lastDonation ?? this.lastDonation,
      isAvailable: isAvailable ?? this.isAvailable,
      totalDonations: totalDonations ?? this.totalDonations,
      weight: weight ?? this.weight,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      licenseNumber: licenseNumber ?? this.licenseNumber,
    );
  }
}
