import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String sellerId;
  final String name;
  final String category;
  final String description;
  final double price;
  final int quantity;
  final String unit;
  final List<String> images;
  final bool isAvailable;
  final GeoPoint location;
  final double rating;
  final int totalRatings;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ProductModel({
    required this.productId,
    required this.sellerId,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    this.images = const [],
    this.isAvailable = true,
    required this.location,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      productId: id,
      sellerId: map['sellerId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      location: map['location'] ?? const GeoPoint(0, 0),
      rating: (map['rating'] ?? 0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'images': images,
      'isAvailable': isAvailable,
      'location': location,
      'rating': rating,
      'totalRatings': totalRatings,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
