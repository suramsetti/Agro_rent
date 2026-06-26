import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/machine_model.dart';
import '../models/driver_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if machine is available at the selected date/time
  Future<bool> checkAvailability({
    required String machineId,
    required DateTime date,
    required double hours,
  }) async {
    try {
      final endTime = date.add(Duration(hours: hours.toInt()));
      
      // Query for overlapping bookings
      final overlappingBookings = await _firestore
          .collection('bookings')
          .where('machineId', isEqualTo: machineId)
          .where('status', whereIn: [
            'pending',
            'confirmed',
            'inProgress',
          ])
          .get();

      for (var doc in overlappingBookings.docs) {
        final bookingData = doc.data();
        final bookingDate = (bookingData['date'] as Timestamp).toDate();
        final bookingHours = bookingData['hours'] as double;
        final bookingEndTime = bookingDate.add(Duration(hours: bookingHours.toInt()));

        // Check for overlap
        if (date.isBefore(bookingEndTime) && endTime.isAfter(bookingDate)) {
          return false; // Machine is not available
        }
      }
      
      return true; // Machine is available
    } catch (e) {
      debugPrint('Error checking availability: $e');
      return false; // On error, assume not available for safety
    }
  }

  // Create a booking with real-time sync
  Future<Map<String, dynamic>> createBooking({
    required Machine machine,
    required Driver? driver,
    required double hours,
    required String paymentMethod,
    required DateTime date,
    required String renterEmail,
    required String renterName,
  }) async {
    try {
      // First check availability
      final isAvailable = await checkAvailability(
        machineId: machine.id,
        date: date,
        hours: hours,
      );

      if (!isAvailable) {
        return {
          'success': false,
          'error': 'Machine is not available at the selected time. Please choose another time.',
        };
      }

      final bookingId = DateTime.now().millisecondsSinceEpoch.toString();
      final bookingData = {
        'id': bookingId,
        'machineId': machine.id,
        'machineName': machine.name,
        'machineRatePerHour': machine.ratePerHour,
        'driverId': driver?.id,
        'driverName': driver?.name,
        'driverRatePerHour': driver?.ratePerHour,
        'hours': hours,
        'paymentMethod': paymentMethod,
        'date': Timestamp.fromDate(date),
        'renterEmail': renterEmail,
        'renterName': renterName,
        'ownerId': machine.ownerId,
        'status': 'pending',
        'paymentStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Create booking in Firestore
      await _firestore.collection('bookings').doc(bookingId).set(bookingData);

      return {
        'success': true,
        'bookingId': bookingId,
        'bookingData': bookingData,
      };
    } catch (e) {
      debugPrint('Error creating booking: $e');
      return {
        'success': false,
        'error': 'Failed to create booking. Please try again.',
      };
    }
  }

  // Stream bookings for a specific machine (real-time updates)
  Stream<QuerySnapshot> getMachineBookingsStream(String machineId) {
    return _firestore
        .collection('bookings')
        .where('machineId', isEqualTo: machineId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Stream bookings for current user (as renter)
  Stream<QuerySnapshot> getUserBookingsStream(String userEmail) {
    return _firestore
        .collection('bookings')
        .where('renterEmail', isEqualTo: userEmail)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Stream bookings for machines owned by current user (as owner)
  Stream<QuerySnapshot> getOwnerBookingsStream(String ownerId) {
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Update booking status in real-time
  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'inProgress') 'startTime': FieldValue.serverTimestamp(),
        if (status == 'completed') ...{
          'endTime': FieldValue.serverTimestamp(),
          'paymentStatus': 'paid',
        },
      });
      return true;
    } catch (e) {
      debugPrint('Error updating booking status: $e');
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return false;
    }
  }

  // Get real-time availability status for a date range
  Stream<List<Map<String, dynamic>>> getAvailabilityStream({
    required String machineId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestore
        .collection('bookings')
        .where('machineId', isEqualTo: machineId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}

