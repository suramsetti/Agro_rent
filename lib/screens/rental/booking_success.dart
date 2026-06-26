import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../receipt/receipt_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmed')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 12),
              Text(
                'Booked ${booking.machineName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${((booking.machineRatePerHour * booking.hours) + (booking.driverRatePerHour * booking.hours)).toStringAsFixed(0)} ₹',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'A rental agreement will be available offline.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptScreen(
                              booking: booking,
                              receiptType: 'booking',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('View Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to home'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
