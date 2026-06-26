import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceModel {
  final String maintenanceId;
  final String machineId;
  final String ownerId;
  final Timestamp serviceDate;
  final String serviceType;
  final String description;
  final double cost;
  final Timestamp nextServiceDate;
  final String serviceProvider;
  final String receiptImage;
  final String notes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  MaintenanceModel({
    required this.maintenanceId,
    required this.machineId,
    required this.ownerId,
    required this.serviceDate,
    required this.serviceType,
    required this.description,
    required this.cost,
    required this.nextServiceDate,
    required this.serviceProvider,
    this.receiptImage = '',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceModel.fromMap(Map<String, dynamic> map, String id) {
    return MaintenanceModel(
      maintenanceId: id,
      machineId: map['machineId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      serviceDate: map['serviceDate'] ?? Timestamp.now(),
      serviceType: map['serviceType'] ?? '',
      description: map['description'] ?? '',
      cost: (map['cost'] ?? 0).toDouble(),
      nextServiceDate: map['nextServiceDate'] ?? Timestamp.now(),
      serviceProvider: map['serviceProvider'] ?? '',
      receiptImage: map['receiptImage'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'machineId': machineId,
      'ownerId': ownerId,
      'serviceDate': serviceDate,
      'serviceType': serviceType,
      'description': description,
      'cost': cost,
      'nextServiceDate': nextServiceDate,
      'serviceProvider': serviceProvider,
      'receiptImage': receiptImage,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
