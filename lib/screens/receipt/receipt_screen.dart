import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking_model.dart';
import '../../services/cart_service.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({
    super.key,
    this.booking,
    this.cartItems,
    this.totalAmount,
    this.receiptType = 'booking',
  });

  final Booking? booking;
  final List<CartItem>? cartItems;
  final double? totalAmount;
  final String receiptType; // 'booking' or 'purchase'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          receiptType == 'booking' ? 'Booking Receipt' : 'Purchase Receipt',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReceipt(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadReceipt(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReceiptHeader(),
            const SizedBox(height: 20),
            _buildReceiptContent(),
            const SizedBox(height: 20),
            _buildReceiptFooter(),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long, color: Colors.green.shade700, size: 48),
          const SizedBox(height: 12),
          Text(
            receiptType == 'booking' ? 'BOOKING CONFIRMED' : 'ORDER CONFIRMED',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Receipt ID: #${_generateReceiptId()}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptContent() {
    if (receiptType == 'booking' && booking != null) {
      return _buildBookingReceipt();
    } else if (receiptType == 'purchase' && cartItems != null) {
      return _buildPurchaseReceipt();
    }
    return const SizedBox.shrink();
  }

  Widget _buildBookingReceipt() {
    final machineTotal = booking!.machineRatePerHour * booking!.hours;
    final driverTotal = booking!.driverRatePerHour * booking!.hours;
    final grandTotal = machineTotal + driverTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Machine Name', booking!.machineName),
          _buildDetailRow('Driver Name', booking!.driverName),
          _buildDetailRow(
            'Date',
            DateFormat('dd MMM yyyy').format(booking!.date),
          ),
          _buildDetailRow(
            'Time',
            '${DateFormat('hh:mm a').format(booking!.startTime)} - ${DateFormat('hh:mm a').format(booking!.endTime)}',
          ),
          _buildDetailRow('Duration', '${booking!.hours} hours'),
          _buildDetailRow('Booking Status', booking!.status.toUpperCase()),
          _buildDetailRow(
            'Payment Status',
            booking!.paymentStatus.toUpperCase(),
          ),
          _buildDetailRow('Payment Method', booking!.paymentMethod),
          const Divider(height: 32),
          const Text(
            'Cost Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Machine Cost',
            '${booking!.machineRatePerHour} ₹ × ${booking!.hours} hrs = ${machineTotal.toStringAsFixed(0)} ₹',
          ),
          _buildDetailRow(
            'Driver Cost',
            '${booking!.driverRatePerHour} ₹ × ${booking!.hours} hrs = ${driverTotal.toStringAsFixed(0)} ₹',
          ),
          const Divider(),
          _buildDetailRow(
            'Total Amount',
            '${grandTotal.toStringAsFixed(0)} ₹',
            isBold: true,
            valueColor: Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseReceipt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Items Ordered', '${cartItems!.length} items'),
          _buildDetailRow('Delivery', 'Within 3-5 business days'),
          _buildDetailRow('Payment Method', 'Cash on Delivery'),
          const Divider(height: 32),
          const Text(
            'Items',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...cartItems!.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.item.name} × ${item.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${(item.item.price * item.quantity).toStringAsFixed(0)} ₹',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          _buildDetailRow(
            'Total Amount',
            '${totalAmount!.toStringAsFixed(0)} ₹',
            isBold: true,
            valueColor: Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Thank you for your ${receiptType == 'booking' ? 'booking' : 'purchase'}!',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            receiptType == 'booking'
                ? 'A rental agreement will be available offline. Please keep this receipt for your records.'
                : 'Your order will be delivered within 3-5 business days. Please keep this receipt for your records.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Support: +91 98765 43210',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _saveToGallery(context),
            icon: const Icon(Icons.save_alt),
            label: const Text('Save to Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _printReceipt(context),
            icon: const Icon(Icons.print),
            label: const Text('Print Receipt'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }

  String _generateReceiptId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(6);
    return receiptType == 'booking' ? 'BK$timestamp' : 'ORD$timestamp';
  }

  void _shareReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _downloadReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality coming soon!')),
    );
  }

  void _saveToGallery(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Receipt saved to gallery!')));
  }

  void _printReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon!')),
    );
  }
}
