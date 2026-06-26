import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import '../receipt/receipt_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  final List<CartItem> cartItems;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your order has been placed successfully',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _orderDetailRow('Items', '${cartItems.length}'),
                    _orderDetailRow(
                      'Total Amount',
                      '${totalAmount.toStringAsFixed(0)} ₹',
                    ),
                    _orderDetailRow('Delivery', 'Within 3-5 days'),
                    _orderDetailRow('Payment Method', 'Cash on Delivery'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Order ID: #ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptScreen(
                              cartItems: cartItems,
                              totalAmount: totalAmount,
                              receiptType: 'purchase',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('View Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Clear cart and navigate back to supplies
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Continue Shopping'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
