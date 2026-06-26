import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MachineModel {
  final String machineId;
  final String ownerId;
  final String name;
  final String type;
  final String brand;
  final String model;
  final int year;
  final double hourlyRate;
  final double dailyRate;
  final double weeklyRate;
  final double monthlyRate;
  final String description;
  final Map<String, dynamic> specifications;
  final List<String> images;
  final bool isAvailable;
  final GeoPoint location;
  final String address;
  final double rating;
  final int totalRatings;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  MachineModel({
    required this.machineId,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.hourlyRate,
    required this.dailyRate,
    required this.weeklyRate,
    required this.monthlyRate,
    required this.description,
    required this.specifications,
    this.images = const [],
    this.isAvailable = true,
    required this.location,
    required this.address,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MachineModel.fromMap(Map<String, dynamic> map, String id) {
    return MachineModel(
      machineId: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      dailyRate: (map['dailyRate'] ?? 0).toDouble(),
      weeklyRate: (map['weeklyRate'] ?? 0).toDouble(),
      monthlyRate: (map['monthlyRate'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      specifications: Map<String, dynamic>.from(map['specifications'] ?? {}),
      images: List<String>.from(map['images'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      location: map['location'] ?? const GeoPoint(0, 0),
      address: map['address'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'type': type,
      'brand': brand,
      'model': model,
      'year': year,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'weeklyRate': weeklyRate,
      'monthlyRate': monthlyRate,
      'description': description,
      'specifications': specifications,
      'images': images,
      'isAvailable': isAvailable,
      'location': location,
      'address': address,
      'rating': rating,
      'totalRatings': totalRatings,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Legacy support for existing code
  String get id => machineId;
  double get ratePerHour => hourlyRate;
  LatLng get position => LatLng(location.latitude, location.longitude);
  String get owner => ''; // This would need to be fetched separately
}

// Keep the old Machine class for backward compatibility
class Machine {
  Machine({
    required this.id,
    required this.name,
    required this.ratePerHour,
    required this.location,
    required this.owner,
    required this.rating,
    required this.position,
    this.ownerId,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double ratePerHour;
  final String location;
  final String owner;
  final double rating;
  final LatLng position;
  final String?
  ownerId; // Phone number of the owner (current user if they own it)
  final String? description;
  final String? imageUrl;

  bool isOwnedBy(String? userId) => ownerId == userId;
}
