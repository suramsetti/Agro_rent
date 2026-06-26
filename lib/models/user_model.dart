import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String name;
  final String phone;
  final String userType; // 'farmer', 'equipment_owner', 'admin'
  final Address address;
  final String profileImage;
  final String aadharNumber;
  final bool isVerified;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    required this.address,
    this.profileImage = '',
    this.aadharNumber = '',
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      userId: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      userType: map['userType'] ?? '',
      address: Address.fromMap(map['address'] ?? {}),
      profileImage: map['profileImage'] ?? '',
      aadharNumber: map['aadharNumber'] ?? '',
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType,
      'address': address.toMap(),
      'profileImage': profileImage,
      'aadharNumber': aadharNumber,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String pincode;
  final GeoPoint coordinates;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    required this.coordinates,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      coordinates: map['coordinates'] ?? const GeoPoint(0, 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'coordinates': coordinates,
    };
  }
}
