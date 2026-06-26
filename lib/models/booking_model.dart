import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Timestamp

class BookingModel {
  final String bookingId;
  final String machineId;
  final String ownerId;
  final String renterId;
  final Timestamp startDate;
  final Timestamp endDate;
  final double totalAmount;
  final String
  status; // 'pending', 'confirmed', 'in_progress', 'completed', 'cancelled'
  final String paymentStatus; // 'pending', 'paid', 'refunded', 'failed'
  final String paymentMethod;
  final String bookingType; // 'hourly', 'daily', 'weekly', 'monthly'
  final String notes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  BookingModel({
    required this.bookingId,
    required this.machineId,
    required this.ownerId,
    required this.renterId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    required this.paymentMethod,
    required this.bookingType,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      bookingId: id,
      machineId: map['machineId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      renterId: map['renterId'] ?? '',
      startDate: map['startDate'] ?? Timestamp.now(),
      endDate: map['endDate'] ?? Timestamp.now(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? '',
      bookingType: map['bookingType'] ?? 'hourly',
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'machineId': machineId,
      'ownerId': ownerId,
      'renterId': renterId,
      'startDate': startDate,
      'endDate': endDate,
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'bookingType': bookingType,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Legacy support
  String get id => bookingId;
}

// Keep the old Booking class for backward compatibility
class Booking {
  final String id;

  // Machine Details
  final String machineId; // Maps to 'meachineid' in DB
  final String machineName;
  final double machineRatePerHour;

  // Driver Details
  final String driverId;
  final String driverName;
  final double driverRatePerHour;

  // Booking Details
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final int hours;

  // User/Renter Details
  final String ownerId;
  final String renterEmail;
  final String renterName;

  // Status & Payment
  final String status;
  final String paymentMethod;
  final String paymentStatus;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.machineId,
    required this.machineName,
    required this.machineRatePerHour,
    required this.driverId,
    required this.driverName,
    required this.driverRatePerHour,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.hours,
    required this.ownerId,
    required this.renterEmail,
    required this.renterName,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firebase Map to Dart Object
  factory Booking.fromMap(Map<String, dynamic> data, String docId) {
    return Booking(
      id: docId,
      // Note: mapping 'meachineid' (from DB) to machineId (Dart)
      machineId: data['meachineid'] ?? '',
      machineName: data['machineName'] ?? '',
      machineRatePerHour: (data['machineRatePerHour'] ?? 0).toDouble(),

      driverId: data['driverId'] ?? '',
      driverName: data['driverName'] ?? '',
      driverRatePerHour: (data['driverRatePerHour'] ?? 0).toDouble(),

      // Handle Timestamps
      date: (data['date'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),

      hours: (data['hours'] ?? 0).toInt(),
      ownerId: data['ownerId'] ?? '',
      renterEmail: data['renterEmail'] ?? '',
      renterName: data['renterName'] ?? '',

      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',

      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert from Dart Object to Firebase Map
  Map<String, dynamic> toMap() {
    return {
      'meachineid': machineId, // Saving with the specific DB spelling
      'machineName': machineName,
      'machineRatePerHour': machineRatePerHour,
      'driverId': driverId,
      'driverName': driverName,
      'driverRatePerHour': driverRatePerHour,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'hours': hours,
      'ownerId': ownerId,
      'renterEmail': renterEmail,
      'renterName': renterName,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
