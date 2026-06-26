import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../services/database_service.dart';

class OwnerTrackingScreen extends StatefulWidget {
  const OwnerTrackingScreen({super.key});

  @override
  State<OwnerTrackingScreen> createState() => _OwnerTrackingScreenState();
}

class _OwnerTrackingScreenState extends State<OwnerTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final myBookings = state.getMyMachineBookings();
    final myOrders = state.getMyItemOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track My Products'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Machinery (${myBookings.length})',
            ),
            Tab(
              text: 'Items (${myOrders.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Machine Bookings Tab
          myBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.agriculture, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No bookings yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'When someone rents your machinery, it will appear here',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: myBookings.length,
                  itemBuilder: (context, index) {
                    final booking = myBookings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: _getStatusIcon(booking.status),
                        title: Text(booking.machineName),
                        subtitle: Text(
                          'Rented by: ${booking.renterName ?? booking.renterEmail ?? "Unknown"}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Status', _getStatusText(booking.status)),
                                _buildInfoRow('Payment', _getPaymentText(booking.paymentStatus)),
                                _buildInfoRow('Hours', booking.hours.toString()),
                                _buildInfoRow('Rate', '${booking.machineRatePerHour.toStringAsFixed(0)} ₹/hour'),
                                _buildInfoRow('Total', '${((booking.machineRatePerHour * booking.hours) + (booking.driverRatePerHour * booking.hours)).toStringAsFixed(0)} ₹'),
                                _buildInfoRow('Started', _formatDateTime(booking.startTime)),
                                _buildInfoRow('Completed', _formatDateTime(booking.endTime)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (booking.status == 'pending')
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await state.updateBookingStatus(
                                            booking.id,
                                            'confirmed',
                                          );
                                          if (mounted) setState(() {});
                                        },
                                        icon: const Icon(Icons.check),
                                        label: const Text('Confirm'),
                                      ),
                                    if (booking.status == 'confirmed')
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await state.updateBookingStatus(
                                            booking.id,
                                            'inProgress',
                                          );
                                          if (mounted) setState(() {});
                                        },
                                        icon: const Icon(Icons.play_arrow),
                                        label: const Text('Start'),
                                      ),
                                    if (booking.status == 'inProgress')
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await state.updateBookingStatus(
                                            booking.id,
                                            'completed',
                                          );
                                          if (mounted) setState(() {});
                                        },
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Complete'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          // Item Orders Tab
          myOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.grass, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'When someone buys your items, it will appear here',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: myOrders.length,
                  itemBuilder: (context, index) {
                    final order = myOrders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: _getStatusIcon(order.status.name),
                        title: Text(order.item.name),
                        subtitle: Text(
                          'Bought by: ${order.buyerName ?? order.buyerPhone ?? "Unknown"}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Status', _getStatusText(order.status.name)),
                                _buildInfoRow('Payment', _getPaymentText(order.paymentStatus.name)),
                                _buildInfoRow('Quantity', '${order.quantity}'),
                                _buildInfoRow('Price per unit', '${order.item.price.toStringAsFixed(0)} ₹'),
                                _buildInfoRow('Total', '${order.totalPrice.toStringAsFixed(0)} ₹'),
                                if (order.deliveryAddress != null)
                                  _buildInfoRow('Delivery Address', order.deliveryAddress!),
                                if (order.deliveryStatus != null)
                                  _buildInfoRow('Delivery', order.deliveryStatus!),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (order.status == BookingStatus.pending)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          state.updateOrderStatus(
                                            order.id,
                                            BookingStatus.confirmed,
                                          );
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.check),
                                        label: const Text('Confirm'),
                                      ),
                                    if (order.status == BookingStatus.confirmed)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          state.updateOrderStatus(
                                            order.id,
                                            BookingStatus.inProgress,
                                          );
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.local_shipping),
                                        label: const Text('Dispatch'),
                                      ),
                                    if (order.status == BookingStatus.inProgress)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          state.updateOrderStatus(
                                            order.id,
                                            BookingStatus.completed,
                                          );
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Delivered'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.pending, color: Colors.orange);
      case 'confirmed':
        return const Icon(Icons.check_circle_outline, color: Colors.blue);
      case 'inProgress':
        return const Icon(Icons.play_circle_outline, color: Colors.purple);
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'inProgress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String _getPaymentText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

