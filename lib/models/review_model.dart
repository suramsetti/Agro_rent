import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String type; // 'machine', 'product', 'user'
  final String targetId;
  final String reviewerId;
  final double rating;
  final String comment;
  final List<String> images;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ReviewModel({
    required this.reviewId,
    required this.type,
    required this.targetId,
    required this.reviewerId,
    required this.rating,
    this.comment = '',
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      reviewId: id,
      type: map['type'] ?? '',
      targetId: map['targetId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'targetId': targetId,
      'reviewerId': reviewerId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
