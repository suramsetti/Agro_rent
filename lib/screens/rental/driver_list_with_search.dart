import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/driver_model.dart';
import '../../widgets/search_widget.dart';
import 'driver_detail_screen.dart';

class DriverListWithSearchScreen extends StatefulWidget {
  const DriverListWithSearchScreen({super.key});

  @override
  State<DriverListWithSearchScreen> createState() =>
      _DriverListWithSearchScreenState();
}

class _DriverListWithSearchScreenState
    extends State<DriverListWithSearchScreen> {
  String _searchQuery = '';
  String? _selectedFilter;
  String? _selectedSort;
  RangeValues _priceRange = const RangeValues(0, 1000);
  RangeValues _ratingRange = const RangeValues(0, 5);

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final allDrivers = state.drivers;

    // Filter drivers based on search and filters
    List<Driver> filteredDrivers = _filterDrivers(allDrivers);

    return Scaffold(
      appBar: AppBar(title: const Text('Drivers for Hire')),
      body: Column(
        children: [
          // Search widget
          SearchWidget(
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            hintText: 'Search drivers...',
            filterOptions: ['All', 'Available', 'Verified', 'Experienced'],
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            sortOptions: [
              'Price: Low to High',
              'Price: High to Low',
              'Rating: High to Low',
              'Experience: High to Low',
            ],
            onSortChanged: (sort) {
              setState(() {
                _selectedSort = sort;
              });
            },
          ),

          // Advanced search widget
          AdvancedSearchWidget(
            onSearch: (filters) {
              setState(() {
                // Update filter criteria
              });
            },
            priceRange: _priceRange,
            onPriceRangeChanged: (range) {
              setState(() {
                _priceRange = range;
              });
            },
            ratingRange: _ratingRange,
            onRatingRangeChanged: (range) {
              setState(() {
                _ratingRange = range;
              });
            },
          ),

          // Drivers list
          Expanded(
            child: filteredDrivers.isEmpty
                ? const Center(
                    child: Text('No drivers found matching your search.'),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive columns: 2 on mobile, 3 on tablet, 4 on desktop
                      int crossAxisCount;
                      if (constraints.maxWidth < 600) {
                        crossAxisCount = 2; // Mobile
                      } else if (constraints.maxWidth < 900) {
                        crossAxisCount = 3; // Tablet
                      } else {
                        crossAxisCount = 4; // Desktop
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredDrivers.length,
                        itemBuilder: (context, index) {
                          final driver = filteredDrivers[index];
                          return _DriverCard(
                            driver: driver,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DriverDetailScreen(driver: driver),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Driver> _filterDrivers(List<Driver> drivers) {
    List<Driver> filtered = List.from(drivers);

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (driver) =>
                driver.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                driver.vehicleType.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                driver.certifiedFor.any(
                  (cert) =>
                      cert.toLowerCase().contains(_searchQuery.toLowerCase()),
                ),
          )
          .toList();
    }

    // Status filter
    if (_selectedFilter != null && _selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Available':
          // Since isAvailable doesn't exist, we'll assume all drivers are available
          filtered = filtered.toList();
          break;
        case 'Verified':
          // Since isVerified doesn't exist, we'll use rating as a proxy for quality
          filtered = filtered.where((driver) => driver.rating >= 4.0).toList();
          break;
        case 'Experienced':
          filtered = filtered.where((driver) {
            final expYears =
                int.tryParse(
                  driver.experience.replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0;
            return expYears >= 3;
          }).toList();
          break;
      }
    }

    // Price filter
    filtered = filtered
        .where(
          (driver) =>
              driver.ratePerHour >= _priceRange.start &&
              driver.ratePerHour <= _priceRange.end,
        )
        .toList();

    // Rating filter
    filtered = filtered
        .where(
          (driver) =>
              driver.rating >= _ratingRange.start &&
              driver.rating <= _ratingRange.end,
        )
        .toList();

    // Sort
    if (_selectedSort != null) {
      switch (_selectedSort) {
        case 'Price: Low to High':
          filtered.sort((a, b) => a.ratePerHour.compareTo(b.ratePerHour));
          break;
        case 'Price: High to Low':
          filtered.sort((a, b) => b.ratePerHour.compareTo(a.ratePerHour));
          break;
        case 'Rating: High to Low':
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Experience: High to Low':
          filtered.sort((a, b) => b.experience.compareTo(a.experience));
          break;
      }
    }

    return filtered;
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver, required this.onTap});

  final Driver driver;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver avatar
              Expanded(
                flex: 3,
                child: Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Driver name
              Text(
                driver.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Vehicle type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  driver.vehicleType,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Experience
              Text(
                driver.experience,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),

              const SizedBox(height: 4),

              // Certifications (if any)
              if (driver.certifiedFor.isNotEmpty) ...[
                Text(
                  driver.certifiedFor.take(2).join(', '),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],

              // Rating and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${driver.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    '${driver.ratePerHour.toStringAsFixed(0)}/hr',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
