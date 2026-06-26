import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverModel {
  final String driverId;
  final String userId;
  final String licenseNumber;
  final Timestamp licenseExpiry;
  final bool isAvailable;
  final GeoPoint currentLocation;
  final double rating;
  final int totalTrips;
  final VehicleDetails vehicleDetails;
  final DriverDocuments documents;
  final bool isVerified;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  DriverModel({
    required this.driverId,
    required this.userId,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.isAvailable = true,
    required this.currentLocation,
    this.rating = 0.0,
    this.totalTrips = 0,
    required this.vehicleDetails,
    required this.documents,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      driverId: map['driverId'] ?? '',
      userId: map['userId'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      licenseExpiry: map['licenseExpiry'] ?? Timestamp.now(),
      isAvailable: map['isAvailable'] ?? true,
      currentLocation: map['currentLocation'] ?? const GeoPoint(0, 0),
      rating: (map['rating'] ?? 0).toDouble(),
      totalTrips: map['totalTrips'] ?? 0,
      vehicleDetails: VehicleDetails.fromMap(map['vehicleDetails'] ?? {}),
      documents: DriverDocuments.fromMap(map['documents'] ?? {}),
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry,
      'isAvailable': isAvailable,
      'currentLocation': currentLocation,
      'rating': rating,
      'totalTrips': totalTrips,
      'vehicleDetails': vehicleDetails.toMap(),
      'documents': documents.toMap(),
      'isVerified': isVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Legacy support
  String get id => driverId;
  LatLng get position =>
      LatLng(currentLocation.latitude, currentLocation.longitude);
}

class VehicleDetails {
  final String type;
  final String number;
  final String capacity;

  VehicleDetails({
    required this.type,
    required this.number,
    required this.capacity,
  });

  factory VehicleDetails.fromMap(Map<String, dynamic> map) {
    return VehicleDetails(
      type: map['type'] ?? '',
      number: map['number'] ?? '',
      capacity: map['capacity'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'type': type, 'number': number, 'capacity': capacity};
  }
}

class DriverDocuments {
  final String license;
  final String aadhar;
  final String rcBook;

  DriverDocuments({
    required this.license,
    required this.aadhar,
    required this.rcBook,
  });

  factory DriverDocuments.fromMap(Map<String, dynamic> map) {
    return DriverDocuments(
      license: map['license'] ?? '',
      aadhar: map['aadhar'] ?? '',
      rcBook: map['rcBook'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'license': license, 'aadhar': aadhar, 'rcBook': rcBook};
  }
}

// Keep the old Driver class for backward compatibility
class Driver {
  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.ratePerHour,
    required this.certifiedFor,
    required this.rating,
    required this.position,
    required this.experience,
    required this.vehicleType,
    this.licenseNumber,
    this.licenseExpiry,
    this.isAvailable = true,
    this.totalTrips = 0,
    this.registeredAt,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final double ratePerHour;
  final List<String> certifiedFor;
  final double rating;
  final LatLng position;
  final String experience;
  final String vehicleType;
  final String? licenseNumber;
  final String? licenseExpiry;
  final bool isAvailable;
  final int totalTrips;
  final DateTime? registeredAt;

  // Check if driver is certified for a specific vehicle type
  bool isCertifiedFor(String vehicleType) {
    return certifiedFor.contains(vehicleType);
  }

  // Create a copy with updated fields
  Driver copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    double? ratePerHour,
    List<String>? certifiedFor,
    double? rating,
    LatLng? position,
    String? experience,
    String? vehicleType,
    String? licenseNumber,
    String? licenseExpiry,
    bool? isAvailable,
    int? totalTrips,
    DateTime? registeredAt,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      ratePerHour: ratePerHour ?? this.ratePerHour,
      certifiedFor: certifiedFor ?? this.certifiedFor,
      rating: rating ?? this.rating,
      position: position ?? this.position,
      experience: experience ?? this.experience,
      vehicleType: vehicleType ?? this.vehicleType,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      isAvailable: isAvailable ?? this.isAvailable,
      totalTrips: totalTrips ?? this.totalTrips,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'ratePerHour': ratePerHour,
      'certifiedFor': certifiedFor,
      'rating': rating,
      'lat': position.latitude,
      'lng': position.longitude,
      'experience': experience,
      'vehicleType': vehicleType,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry,
      'isAvailable': isAvailable,
      'totalTrips': totalTrips,
      'registeredAt': registeredAt?.toIso8601String(),
    };
  }

  // Create from map for database retrieval
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      ratePerHour: (map['ratePerHour'] as num).toDouble(),
      certifiedFor: List<String>.from(map['certifiedFor'] as List),
      rating: (map['rating'] as num).toDouble(),
      position: LatLng(
        (map['lat'] as num).toDouble(),
        (map['lng'] as num).toDouble(),
      ),
      experience: map['experience'] as String,
      vehicleType: map['vehicleType'] as String,
      licenseNumber: map['licenseNumber'] as String?,
      licenseExpiry: map['licenseExpiry'] as String?,
      isAvailable: map['isAvailable'] as bool? ?? true,
      totalTrips: map['totalTrips'] as int? ?? 0,
      registeredAt: map['registeredAt'] != null
          ? DateTime.parse(map['registeredAt'] as String)
          : null,
    );
  }
}
