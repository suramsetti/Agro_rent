import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/item_model.dart';
import 'item_delivery_details.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _addressController = TextEditingController();
  final List<LeftoverItem> _cartItems = []; // Demo cart items

  @override
  void initState() {
    super.initState();
    _loadDemoItems();
  }

  void _loadDemoItems() {
    // Add some demo items to cart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = AppScope.state(context);
      if (state.leftovers.isNotEmpty) {
        setState(() {
          _cartItems.addAll(state.leftovers.take(3));
        });
      }
    });
  }

  double get _totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.discountedPrice);
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _proceedToBuy() {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    // Show delivery details for first item
    if (_cartItems.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDeliveryDetailsScreen(item: _cartItems.first),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _cartItems.clear();
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Cart cleared')));
              },
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: Column(
        children: [
          // Delivery Address Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'Enter your delivery address',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),

          // Cart Items
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add items from supplies section',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Item Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _buildMappedImage(item.name),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Item Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      item.quantity,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${item.discountedPrice.toStringAsFixed(0)} ₹',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Remove Button
                              IconButton(
                                onPressed: () => _removeItem(index),
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Checkout Section
          if (_cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_totalAmount.toStringAsFixed(0)} ₹',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _proceedToBuy,
                      icon: const Icon(Icons.payment),
                      label: const Text('Proceed to Buy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMappedImage(String itemName) {
    String assetPath;
    final lowerName = itemName.toLowerCase();

    if (lowerName.contains('urea')) {
      assetPath = 'assets/image_529fe3.jpg';
    } else if (lowerName.contains('dap') || lowerName.contains('diammonium')) {
      assetPath = 'assets/image_529957.jpg';
    } else if (lowerName.contains('potash') || lowerName.contains('muriate')) {
      assetPath = 'assets/image_529c1d.jpg';
    } else {
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
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }
}
