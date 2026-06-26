import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../services/storage_service.dart';
import '../../services/cart_service.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  void _loadSavedAddress() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = AppScope.state(context);
      if (state.deliveryAddress != null) {
        setState(() {
          _addressController.text = state.deliveryAddress!;
        });
      }
    });
  }

  void _saveAddress(String address) {
    final state = AppScope.state(context);
    if (address.isNotEmpty) {
      state.setDeliveryAddress(address);
    } else {
      state.clearDeliveryAddress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final cartService = state.cartService;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart (${cartService.itemCount} items)'),
        actions: [
          if (cartService.cartItems.isNotEmpty)
            IconButton(
              onPressed: () {
                _showClearCartDialog(context, cartService);
              },
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: Column(
        children: [
          // Delivery Address Section - more compact
          Container(
            margin: EdgeInsets.all(isMobile ? 8 : 12),
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 8),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'Enter your delivery address',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 12,
                      vertical: isMobile ? 8 : 12,
                    ),
                  ),
                  maxLines: isMobile ? 2 : 3,
                  onChanged: (value) => _saveAddress(value),
                  style: TextStyle(fontSize: isMobile ? 13 : 14),
                ),
              ],
            ),
          ),

          // Cart Items
          Expanded(
            child: cartService.cartItems.isEmpty
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 16,
                    ),
                    itemCount: cartService.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartService.cartItems[index];
                      final item = cartItem.item;
                      return _CartItemCard(
                        cartItem: cartItem,
                        onQuantityChanged: (quantity) {
                          cartService.updateQuantity(item.id, quantity);
                        },
                        onRemove: () {
                          cartService.removeFromCart(item.id);
                        },
                      );
                    },
                  ),
          ),

          // Price Summary Section
          if (cartService.cartItems.isNotEmpty)
            _PriceSummarySection(
              cartService: cartService,
              addressController: _addressController,
              isMobile: isMobile,
            ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, cartService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              cartService.clearCart();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cart cleared')));
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final item = cartItem.item;
    final quantity = cartItem.quantity;
    final itemTotal = item.discountedPrice * quantity;
    final savings = (item.price - item.discountedPrice) * quantity;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 6 : 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main item row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image - smaller on mobile
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: isMobile ? 50 : 60,
                    height: isMobile ? 50 : 60,
                    child: StorageService.createImageWidget(
                      item.imageUrl,
                      machineName: item.name,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 8),
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 11 : 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        item.quantity,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isMobile ? 9 : 11,
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Row(
                        children: [
                          Text(
                            '${item.discountedPrice.toStringAsFixed(0)} ₹',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.price.toStringAsFixed(0)} ₹',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade600,
                              fontSize: isMobile ? 9 : 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Remove Button
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  iconSize: isMobile ? 18 : 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 6 : 8),
            // Quantity and Total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Controls - more compact
                Row(
                  children: [
                    Text(
                      'Qty: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 10 : 11,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => onQuantityChanged(quantity - 1),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 4 : 6,
                                vertical: isMobile ? 1 : 2,
                              ),
                              child: Icon(
                                Icons.remove,
                                size: isMobile ? 12 : 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 6 : 8,
                              vertical: isMobile ? 1 : 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                vertical: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                            child: Text(
                              '$quantity',
                              style: TextStyle(fontSize: isMobile ? 10 : 12),
                            ),
                          ),
                          InkWell(
                            onTap: () => onQuantityChanged(quantity + 1),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 4 : 6,
                                vertical: isMobile ? 1 : 2,
                              ),
                              child: Icon(Icons.add, size: isMobile ? 12 : 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Total and Savings
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${itemTotal.toStringAsFixed(0)} ₹',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                    if (savings > 0)
                      Text(
                        'Save ${savings.toStringAsFixed(0)} ₹',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: isMobile ? 9 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMappedImage(String itemName) {
    String assetPath;
    final lowerName = itemName.toLowerCase();

    debugPrint('Building cart image for: $itemName');

    if (lowerName.contains('urea')) {
      assetPath = 'assets/image_529fe3.jpg';
      debugPrint('Using urea image: $assetPath');
    } else if (lowerName.contains('dap') || lowerName.contains('diammonium')) {
      assetPath = 'assets/image_529957.jpg';
      debugPrint('Using DAP image: $assetPath');
    } else if (lowerName.contains('potash') || lowerName.contains('muriate')) {
      assetPath = 'assets/image_529c1d.jpg';
      debugPrint('Using potash image: $assetPath');
    } else if (lowerName.contains('seed') || lowerName.contains('seeds')) {
      assetPath =
          'assets/image_529fe3.jpg'; // Use urea image as fallback for seeds
      debugPrint('Using seed fallback image: $assetPath');
    } else if (lowerName.contains('fertilizer') ||
        lowerName.contains('manure')) {
      assetPath =
          'assets/image_529957.jpg'; // Use DAP image as fallback for fertilizers
      debugPrint('Using fertilizer fallback image: $assetPath');
    } else {
      // Generic fallback for any agricultural product
      debugPrint(
        'No matching product found for: $itemName - using generic placeholder',
      );
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 24, color: Colors.green.shade600),
            const SizedBox(height: 2),
            Text(
              'Product',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Cart image loading error for $assetPath: $error');
        debugPrint('Stack trace: $stackTrace');
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 24,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 2),
              Text(
                'Image',
                style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PriceSummarySection extends StatelessWidget {
  const _PriceSummarySection({
    required this.cartService,
    required this.addressController,
    required this.isMobile,
  });

  final CartService cartService;
  final TextEditingController addressController;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _priceRow(
            'Subtotal',
            '${cartService.subtotal.toStringAsFixed(0)} ₹',
            false,
            isMobile,
          ),
          _priceRow(
            'Delivery',
            cartService.deliveryCharge == 0
                ? 'FREE'
                : '${cartService.deliveryCharge.toStringAsFixed(0)} ₹',
            cartService.deliveryCharge == 0,
            isMobile,
          ),
          if (cartService.savings > 0)
            _priceRow(
              'Total Savings',
              '-${cartService.savings.toStringAsFixed(0)} ₹',
              true,
              isMobile,
            ),
          const Divider(),
          _priceRow(
            'Total Amount',
            '${cartService.total.toStringAsFixed(0)} ₹',
            false,
            isMobile,
            isBold: true,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  _proceedToBuy(context, addressController, cartService),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
              ),
              child: Text(
                'Proceed to Buy (${cartService.itemCount} items)',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value,
    bool isGreen,
    bool isMobile, {
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 2 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: isGreen ? Colors.green : null,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToBuy(
    BuildContext context,
    TextEditingController addressController,
    CartService cartService,
  ) {
    if (addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    // Show order confirmation screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          cartItems: cartService.cartItems,
          totalAmount: cartService.total,
        ),
      ),
    );
  }
}
