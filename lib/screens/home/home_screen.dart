import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../l10n/app_localizations.dart';
import '../rental/machine_list_with_search.dart';
import '../marketplace/supplies_grid_with_search.dart';
import '../tracking/tracking_screen.dart';
import '../rental/driver_list_with_search.dart';
import '../rental/driver_registration_screen.dart';
import 'add_machine_screen.dart';
import '../marketplace/sell_item_form.dart';
import 'profile_screen.dart';
import '../profile/booking_management_screen.dart';
import '../../widgets/schemes_carousel.dart';
import '../../widgets/search_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  // Search state for each tab
  String _machineSearchQuery = '';
  String? _selectedMachineFilter;
  String? _selectedMachineSort;

  String _suppliesSearchQuery = '';
  String? _selectedSuppliesCategory;
  double _suppliesPriceRange = 5000;

  String _driverSearchQuery = '';
  String? _selectedDriverType;
  double _driverRating = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final l10n = AppLocalizations.of(context)!;

    final tabs = [
      MachineListWithSearchScreen(
        searchQuery: _machineSearchQuery,
        selectedFilter: _selectedMachineFilter,
        selectedSort: _selectedMachineSort,
      ),
      const SuppliesGridWithSearchScreen(),
      const DriverListWithSearchScreen(),
      const TrackingScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookingManagementScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_today),
            tooltip: 'My Bookings',
          ),
          Row(
            children: [
              Icon(state.offlineMode ? Icons.wifi_off : Icons.wifi, size: 18),
              Switch(value: state.offlineMode, onChanged: state.setOffline),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search widgets - show based on current tab
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchWidget(),
          ),

          // Government Schemes Carousel - only show on machinery tab
          if (index == 0) const SchemesCarousel(),

          // Tab content
          Expanded(child: tabs[index]),
        ],
      ),
      floatingActionButton:
          (index == 0 || index == 1) &&
              state.sellingModeEnabled &&
              !state.isSellerBanned
          ? FloatingActionButton.extended(
              onPressed: () {
                if (index == 0) {
                  // Machinery tab - add machine
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddMachineScreen()),
                  );
                } else {
                  // Supplies tab - go to sell item form
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellItemFormScreen(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: Text(index == 0 ? l10n.addMachine : l10n.addItem),
            )
          : index == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                // Drivers tab - register as driver
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DriverRegistrationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Register as Driver'),
              backgroundColor: Colors.green,
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.agriculture),
            label: l10n.machinery,
          ),

          // --- UPDATED: SUPPLIES TAB WITH CUSTOM IMAGE ---
          NavigationDestination(
            icon: SizedBox(
              height: 24,
              width: 24,
              child: Image.asset(
                'assets/image_529c1d.jpg', // Potash Bag Image
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.grass,
                ), // Fallback to grass icon if image missing
              ),
            ),
            selectedIcon: SizedBox(
              height: 28, // Slightly bigger when selected
              width: 28,
              child: Image.asset(
                'assets/image_529c1d.jpg',
                fit: BoxFit.contain,
              ),
            ),
            label: l10n.supplies,
          ),

          // ----------------------------------------------
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: 'Drivers',
          ),

          NavigationDestination(
            icon: const Icon(Icons.map),
            label: l10n.tracking,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchWidget() {
    switch (index) {
      case 0: // Machinery tab
        return SearchWidget(
          onSearch: (query) {
            setState(() {
              _machineSearchQuery = query;
            });
          },
          hintText: 'Search machinery...',
          filterOptions: [
            'All',
            'Tractors',
            'Harvesters',
            'Planters',
            'Sprayers',
            'Drones',
          ],
          onFilterChanged: (filter) {
            setState(() {
              _selectedMachineFilter = filter;
            });
          },
          sortOptions: [
            'Price: Low to High',
            'Price: High to Low',
            'Rating: High to Low',
            'Name: A to Z',
          ],
          onSortChanged: (sort) {
            setState(() {
              _selectedMachineSort = sort;
            });
          },
        );

      default:
        return const SizedBox.shrink(); // No search for other tabs
    }
  }
}
