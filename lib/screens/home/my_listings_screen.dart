import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../l10n/app_localizations.dart';
import '../../services/database_service.dart';
import '../marketplace/sell_item_form.dart' show SellItemFormScreen;
import '../rental/machine_detail.dart';
import 'add_machine_screen.dart';
import 'owner_tracking_screen.dart';
import '../../debug_database_images.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
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
    final l10n = AppLocalizations.of(context)!;
    final myMachines = state.getMyMachines();
    final myItems = state.getMyItems();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myListings),
        actions: [
          IconButton(
            icon: const Icon(Icons.track_changes),
            tooltip: 'Track Products',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OwnerTrackingScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Database Images',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DatabaseImagesDebugScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.myMachines),
            Tab(text: l10n.myItems),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Machines Tab
          Column(
            children: [
              if (myMachines.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.agriculture, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No machines listed yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start renting out your machinery',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: myMachines.length,
                    itemBuilder: (context, index) {
                      final machine = myMachines[index];
                      final bookings = state.bookings
                          .where((b) => b.machineId == machine.id)
                          .toList();
                      final activeBookings = bookings
                          .where((b) => b.status != 'completed' &&
                              b.status != 'cancelled')
                          .length;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              const Icon(Icons.agriculture, size: 40),
                              if (activeBookings > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$activeBookings',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(machine.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${machine.ratePerHour.toStringAsFixed(0)} ₹/hour • ${machine.location}',
                              ),
                              if (activeBookings > 0)
                                Text(
                                  '$activeBookings active booking${activeBookings > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (activeBookings > 0)
                                IconButton(
                                  icon: const Icon(Icons.track_changes),
                                  tooltip: 'Track bookings',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const OwnerTrackingScreen(),
                                      ),
                                    );
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // TODO: Edit machine
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // TODO: Delete machine
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MachineDetailScreen(machine: machine),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddMachineScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addMachine),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
          // My Items Tab
          Column(
            children: [
              if (myItems.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.grass, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No items listed yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start selling your supplies',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: myItems.length,
                    itemBuilder: (context, index) {
                      final item = myItems[index];
                      final itemOrders = state.orders
                          .where((o) => o.item.id == item.id)
                          .toList();
                      final activeOrders = itemOrders
                          .where((o) => o.status != BookingStatus.completed &&
                              o.status != BookingStatus.cancelled)
                          .length;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              const Icon(Icons.grass, size: 40),
                              if (activeOrders > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$activeOrders',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.discountedPrice.toStringAsFixed(0)} ₹ • ${item.quantity} • ${item.distance}',
                              ),
                              if (activeOrders > 0)
                                Text(
                                  '$activeOrders active order${activeOrders > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (activeOrders > 0)
                                IconButton(
                                  icon: const Icon(Icons.track_changes),
                                  tooltip: 'Track orders',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const OwnerTrackingScreen(),
                                      ),
                                    );
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // TODO: Edit item
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // TODO: Delete item
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SellItemFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addItem),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

