import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String favoriteId;
  final String userId;
  final String type; // 'machine', 'product'
  final String itemId;
  final Timestamp createdAt;

  FavoriteModel({
    required this.favoriteId,
    required this.userId,
    required this.type,
    required this.itemId,
    required this.createdAt,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map, String id) {
    return FavoriteModel(
      favoriteId: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      itemId: map['itemId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'itemId': itemId,
      'createdAt': createdAt,
    };
  }
}
