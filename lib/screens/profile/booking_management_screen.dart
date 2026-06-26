import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/booking_model.dart';
import '../../services/database_service.dart';

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings & Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Machine Bookings'),
              Tab(text: 'Item Orders'),
            ],
          ),
        ),
        body: TabBarView(children: [_MachineBookingsTab(), _ItemOrdersTab()]),
      ),
    );
  }
}

class _MachineBookingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final myBookings = state.getMyMachineBookings();

    if (myBookings.isEmpty) {
      return const Center(child: Text('No machine bookings found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myBookings.length,
      itemBuilder: (context, index) {
        final booking = myBookings[index];
        return _MachineBookingCard(booking: booking);
      },
    );
  }
}

class _ItemOrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final myOrders = state.getMyItemOrders();

    if (myOrders.isEmpty) {
      return const Center(child: Text('No item orders found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myOrders.length,
      itemBuilder: (context, index) {
        final order = myOrders[index];
        return _ItemOrderCard(order: order);
      },
    );
  }
}

class _MachineBookingCard extends StatelessWidget {
  const _MachineBookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final canCancel =
        booking.status == 'pending' || booking.status == 'confirmed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.machineName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Booking details
            _buildDetailRow(
              Icons.calendar_today,
              'Date',
              '${booking.date.day}/${booking.date.month}/${booking.date.year}',
            ),
            _buildDetailRow(
              Icons.access_time,
              'Time',
              '${booking.startTime.hour}:${booking.startTime.minute.toString().padLeft(2, '0')} - ${booking.endTime.hour}:${booking.endTime.minute.toString().padLeft(2, '0')}',
            ),
            _buildDetailRow(
              Icons.hourglass_empty,
              'Duration',
              '${booking.hours} hours',
            ),
            _buildDetailRow(Icons.person, 'Renter', booking.renterName),
            if (booking.driverName.isNotEmpty)
              _buildDetailRow(Icons.drive_eta, 'Driver', booking.driverName),

            const SizedBox(height: 12),

            // Pricing
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${(booking.machineRatePerHour * booking.hours + booking.driverRatePerHour * booking.hours).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            if (canCancel)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showCancelConfirmation(context, booking, false),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        'Cancel Booking',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'inprogress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCancelConfirmation(
    BuildContext context,
    Booking booking,
    bool isOrder,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel this booking for ${booking.machineName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              final state = AppScope.state(context);
              await state.cancelBooking(booking.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ItemOrderCard extends StatelessWidget {
  const _ItemOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final canCancel =
        order.status == BookingStatus.pending ||
        order.status == BookingStatus.confirmed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status.name),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Order details
            _buildDetailRow(
              Icons.shopping_cart,
              'Quantity',
              '${order.quantity}',
            ),
            _buildDetailRow(
              Icons.person,
              'Buyer',
              order.buyerName ?? 'Unknown',
            ),
            _buildDetailRow(
              Icons.calendar_today,
              'Date',
              '${order.date.day}/${order.date.month}/${order.date.year}',
            ),
            if (order.buyerPhone != null)
              _buildDetailRow(Icons.phone, 'Phone', order.buyerPhone!),
            if (order.deliveryAddress != null)
              _buildDetailRow(
                Icons.location_on,
                'Delivery',
                order.deliveryAddress!,
              ),

            const SizedBox(height: 12),

            // Pricing
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${order.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            if (canCancel)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showCancelConfirmation(context, order, true),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        'Cancel Order',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'inprogress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCancelConfirmation(
    BuildContext context,
    Order order,
    bool isOrder,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
          'Are you sure you want to cancel this order for ${order.item.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              final state = AppScope.state(context);
              state.cancelOrder(order.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order cancelled successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
