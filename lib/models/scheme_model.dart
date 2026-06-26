import 'package:flutter/material.dart';

class Scheme {
  final String id;
  final String title;
  final String category;
  final String description;
  final String benefits;
  final String eligibility;
  final String documents;
  final String applicationProcess;
  final String registrationDeadline;
  final IconData icon;
  final Color color;

  Scheme({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.benefits,
    required this.eligibility,
    required this.documents,
    required this.applicationProcess,
    required this.registrationDeadline,
    required this.icon,
    required this.color,
  });

  bool isRegistrationDeadlineNear() {
    // Check if deadline is within 7 days from today
    try {
      final deadlineDate = DateTime.parse(registrationDeadline);
      final today = DateTime.now();
      final difference = deadlineDate.difference(today);
      return difference.inDays <= 7 && difference.inDays >= 0;
    } catch (e) {
      // If date parsing fails, assume no deadline urgency
      return false;
    }
  }

  String get formattedDeadline {
    try {
      final deadlineDate = DateTime.parse(registrationDeadline);
      return '${deadlineDate.day}/${deadlineDate.month}/${deadlineDate.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
