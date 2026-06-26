import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/item_model.dart';
import '../../services/storage_service.dart';
import '../../widgets/search_widget.dart';
import 'cart_screen.dart';
import 'sell_item_form.dart';

class SuppliesGridWithSearchScreen extends StatefulWidget {
  const SuppliesGridWithSearchScreen({super.key});

  @override
  State<SuppliesGridWithSearchScreen> createState() =>
      _SuppliesGridWithSearchScreenState();
}

class _SuppliesGridWithSearchScreenState
    extends State<SuppliesGridWithSearchScreen> {
  String _searchQuery = '';
  String? _selectedFilter;
  String? _selectedSort;
  RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final allItems = state.leftovers;

    // Filter items based on search and filters
    List<LeftoverItem> filteredItems = _filterItems(allItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplies'),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                tooltip: 'View Cart',
              ),
              if (state.cartService.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${state.cartService.itemCount}',
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
        ],
      ),
      body: Column(
        children: [
          // Search widget
          SearchWidget(
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            hintText: 'Search supplies...',
            filterOptions: [
              'All',
              'Fertilizers',
              'Pesticides',
              'Seeds',
              'Tools',
            ],
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            sortOptions: [
              'Price: Low to High',
              'Price: High to Low',
              'Distance: Near to Far',
              'Name: A to Z',
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
              // Handle advanced search filters
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
          ),

          // Items grid
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text('No items found matching your search.'),
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
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _ItemCard(
                            item: item,
                            onTap: () => _showItemDetails(context, item),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (state.sellingModeEnabled) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SellItemFormScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enable selling mode in profile to add items',
                    ),
                  ),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          // Test button for creating a user-owned item
          FloatingActionButton.small(
            onPressed: () => _createTestItem(context),
            tooltip: 'Create Test Item',
            backgroundColor: Colors.purple,
            child: const Icon(Icons.science),
          ),
        ],
      ),
    );
  }

  List<LeftoverItem> _filterItems(List<LeftoverItem> items) {
    List<LeftoverItem> filtered = List.from(items);

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (item.description?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                item.seller.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Category filter
    if (_selectedFilter != null && _selectedFilter != 'All') {
      filtered = filtered
          .where(
            (item) => item.name.toLowerCase().contains(
              _selectedFilter!.toLowerCase(),
            ),
          )
          .toList();
    }

    // Price filter
    filtered = filtered
        .where(
          (item) =>
              item.discountedPrice >= _priceRange.start &&
              item.discountedPrice <= _priceRange.end,
        )
        .toList();

    // Sort
    if (_selectedSort != null) {
      switch (_selectedSort) {
        case 'Price: Low to High':
          filtered.sort(
            (a, b) => a.discountedPrice.compareTo(b.discountedPrice),
          );
          break;
        case 'Price: High to Low':
          filtered.sort(
            (a, b) => b.discountedPrice.compareTo(a.discountedPrice),
          );
          break;
        case 'Distance: Near to Far':
          filtered.sort(
            (a, b) => _parseDistance(
              a.distance,
            ).compareTo(_parseDistance(b.distance)),
          );
          break;
        case 'Name: A to Z':
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
      }
    }

    return filtered;
  }

  double _parseDistance(String distance) {
    final match = RegExp(r'[\d.]+').firstMatch(distance);
    return match != null ? double.tryParse(match.group(0) ?? '0') ?? 0 : 0;
  }

  void _showItemDetails(BuildContext context, LeftoverItem item) {
    // Navigate to item details or show bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (context) => _ItemDetailsSheet(item: item),
    );
  }

  void _createTestItem(BuildContext context) {
    final state = AppScope.state(context);
    final testItem = LeftoverItem(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Test Item (Delete Me)',
      quantity: '1 kg',
      discount: 0.1,
      price: 100,
      seller: 'Test Seller',
      distance: '0.5 km',
      sellerId: state.userEmail, // This makes it owned by the current user
      description: 'This is a test item for testing delete functionality',
      imageUrl: null,
    );

    state.addUserItem(testItem);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test item added! You should see a delete button on it.'),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.onTap});

  final LeftoverItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final isUserItem = item.isOwnedBy(state.userEmail);

    debugPrint('Building item card for: ${item.name}');
    debugPrint('User email: ${state.userEmail}');
    debugPrint('Is user item: $isUserItem');
    debugPrint('Item seller ID: ${item.sellerId}');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with delete button overlay for user items
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        child: item.imageUrl != null
                            ? Image.asset(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    // Delete button for user items
                    if (isUserItem)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () =>
                                _showDeleteConfirmation(context, item),
                            tooltip: 'Delete item',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Service Area (Distance) - more prominent
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Service: ${item.distance}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Stock Availability
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.inStock
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.inStock
                          ? Icons.inventory
                          : Icons.inventory_2_outlined,
                      size: 12,
                      color: item.inStock
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      item.inStock ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        color: item.inStock
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Quantity
              Text(
                item.quantity,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),

              const SizedBox(height: 4),

              // Price and Discount
              Row(
                children: [
                  Text(
                    '${item.discountedPrice.toStringAsFixed(0)} ₹',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  if (item.discount > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${item.price.toStringAsFixed(0)} ₹',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),

              if (item.discount > 0) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(item.discount * 100).toStringAsFixed(0)}% OFF',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, LeftoverItem item) {
    debugPrint('Delete confirmation for item: ${item.name}, ID: ${item.id}');
    debugPrint('User email: ${AppScope.state(context).userEmail}');
    debugPrint('Item seller ID: ${item.sellerId}');
    debugPrint(
      'Is owned by user: ${item.isOwnedBy(AppScope.state(context).userEmail)}',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint('Delete button pressed for item: ${item.id}');
              final state = AppScope.state(context);
              state.deleteUserItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ItemDetailsSheet extends StatelessWidget {
  const _ItemDetailsSheet({required this.item});

  final LeftoverItem item;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Image
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Details
          Text(
            'Quantity: ${item.quantity}',
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 8),

          Text('Seller: ${item.seller}', style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 8),

          Text(
            'Distance: ${item.distance}',
            style: const TextStyle(fontSize: 16),
          ),

          if (item.description != null) ...[
            const SizedBox(height: 8),
            Text(
              'Description: ${item.description}',
              style: const TextStyle(fontSize: 16),
            ),
          ],

          const SizedBox(height: 16),

          // Price
          Row(
            children: [
              Text(
                '${item.discountedPrice.toStringAsFixed(0)} ₹',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (item.discount > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '${item.price.toStringAsFixed(0)} ₹',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey.shade500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${(item.discount * 100).toStringAsFixed(0)}% OFF',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // Add to Cart Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                state.cartService.addToCart(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} added to cart')),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
