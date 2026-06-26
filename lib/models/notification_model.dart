import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final String type; // 'booking', 'order', 'payment', 'system'
  final bool isRead;
  final String referenceId;
  final Timestamp createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.referenceId,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      notificationId: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      isRead: map['isRead'] ?? false,
      referenceId: map['referenceId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'referenceId': referenceId,
      'createdAt': createdAt,
    };
  }
}
