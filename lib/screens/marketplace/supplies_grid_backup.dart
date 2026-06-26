import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/item_model.dart';
import 'sell_item_form.dart';
import 'item_delivery_details.dart';
import 'cart_screen.dart';

class SuppliesGridScreen extends StatelessWidget {
  const SuppliesGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplies'),
        actions: [
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
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive columns: aim for ~180px cards, min 2 columns
          final desiredCardWidth = 180.0;
          final columns = (constraints.maxWidth / desiredCardWidth).floor().clamp(2, 4);
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 0.72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: state.leftovers.length,
            itemBuilder: (context, index) {
              final item = state.leftovers[index];
              return _SupplyCard(
                item: item,
                onTap: () => _showItemSheet(context, item, state.leftovers),
              );
            },
          );
        },
      ),
      floatingActionButton: state.sellingModeEnabled
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellItemFormScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Sell leftover'),
            )
          : null,
    );
  }
}

class _SupplyCard extends StatelessWidget {
  const _SupplyCard({required this.item, this.onTap});

  final LeftoverItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  // REPLACED: Uses helper to pick local asset based on name
                  child: _buildMappedImage(item.name),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.quantity,
                style: const TextStyle(color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
// Put Discount and Distance on the same line
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      '${(item.discount * 100).toStringAsFixed(0)}% off',
      style: const TextStyle(color: Colors.green, fontSize: 12),
    ),
    Text(
      item.distance,
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    ),
  ],
),
const SizedBox(height: 4),
Text(
  '${item.price.toStringAsFixed(0)} ₹',
  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
            ],
          ),
        ),
      ),
    );
  }
}

void _showItemSheet(BuildContext context, LeftoverItem item, List<LeftoverItem> all) {
  final similar = all
      .where((i) => i.id != item.id && i.name.split(' ').first.toLowerCase() == item.name.split(' ').first.toLowerCase())
      .take(6)
      .toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(item.quantity, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Text('${item.price.toStringAsFixed(0)} ₹', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${(item.discount * 100).toStringAsFixed(0)}% off', style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  // REPLACED: Uses helper to pick local asset based on name
                  child: _buildMappedImage(item.name),
                ),
              ),
              if (item.description != null) ...[
                const SizedBox(height: 8),
                Text(item.description!, style: const TextStyle(color: Colors.black87)),
              ],
              const SizedBox(height: 12),
              if (similar.isNotEmpty) ...[
                const Text('Similar items', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (c, i) {
                      final s = similar[i];
                      return SizedBox(
                        width: 160,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    // REPLACED: Uses helper to pick local asset based on name
                                    child: _buildMappedImage(s.name),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(s.quantity, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                                const Spacer(),
                                Text('${(s.discount * 100).toStringAsFixed(0)}% off', style: const TextStyle(color: Colors.green)),
                                Text('${s.price.toStringAsFixed(0)} ₹', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: similar.length,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showItemDeliveryDetails(context, item);
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Book Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _addToCart(context, item);
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _addToCart(BuildContext context, LeftoverItem item) {
  final state = AppScope.state(context);
  
  // Show snackbar confirmation
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${item.name} added to cart'),
      action: SnackBarAction(
        label: 'View Cart',
        onPressed: () {
          _showCartScreen(context);
        },
      ),
    ),
  );
}

void _showCartScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CartScreen()),
  );
}

void _showItemDeliveryDetails(BuildContext context, LeftoverItem item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ItemDeliveryDetailsScreen(item: item),
    ),
  );
}

// --- NEW HELPER FUNCTION ---
// This maps the item name to the correct uploaded image
Widget _buildMappedImage(String itemName) {
  String assetPath;
  final lowerName = itemName.toLowerCase();

  if (lowerName.contains('urea')) {
    assetPath = 'assets/image_529fe3.jpg'; // The Urea Bag image
  } else if (lowerName.contains('dap') || lowerName.contains('diammonium')) {
    assetPath = 'assets/image_529957.jpg'; // The DAP Bag image
  } else if (lowerName.contains('potash') || lowerName.contains('muriate')) {
    assetPath = 'assets/image_529c1d.jpg'; // The Potash Bag image
  } else {
    // Fallback if no specific name matches
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.image, color: Colors.grey)),
    );
  }

  return Image.asset(
    assetPath,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    },
  );
}