import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/item_model.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';

class SellItemFormScreen extends StatefulWidget {
  const SellItemFormScreen({super.key});

  @override
  State<SellItemFormScreen> createState() => _SellItemFormScreenState();
}

class _SellItemFormScreenState extends State<SellItemFormScreen> {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final discountCtrl = TextEditingController(text: '0.2');
  final _storage = StorageService();
  String? imageUrl;
  bool uploadingImage = false;
  bool inStock = true; // Stock availability toggle

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);

    // Check if selling mode is enabled
    if (!state.sellingModeEnabled) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sell leftover')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Selling Mode Required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enable selling mode from your profile to add items.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Go to Profile'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Check if seller is banned due to low rating
    if (state.isSellerBanned) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sell leftover')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.block, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Selling disabled',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Your selling feature is blocked due to low rating.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sell leftover')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Item name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: qtyCtrl,
            decoration: const InputDecoration(
              labelText: 'Quantity (e.g., 5 kg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceCtrl,
            decoration: const InputDecoration(
              labelText: 'Price (₹)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: discountCtrl,
            decoration: const InputDecoration(
              labelText: 'Discount (0.0 - 1.0)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          // Stock Availability Toggle
          Row(
            children: [
              const Icon(Icons.inventory, size: 20),
              const SizedBox(width: 8),
              const Text('Stock Status:'),
              const Spacer(),
              Switch(
                value: inStock,
                onChanged: (value) {
                  setState(() {
                    inStock = value;
                  });
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                inStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  color: inStock ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: uploadingImage
                    ? null
                    : () async {
                        setState(() => uploadingImage = true);
                        final result = await _storage.pickAndUpload(
                          folder: 'items',
                        );
                        if (mounted) {
                          setState(() {
                            imageUrl = result['base64'];
                            uploadingImage = false;
                          });
                          if (result['base64'] != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image stored successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image not selected'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                icon: uploadingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.image),
                label: Text(uploadingImage ? 'Uploading...' : 'Add photo'),
              ),
              const SizedBox(width: 12),
              if (imageUrl != null)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          // Image preview section
          if (imageUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _storage.imageFromBase64String(imageUrl!),
              ),
            ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Post item',
            onPressed: () {
              final state = AppScope.state(context);
              final item = LeftoverItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text,
                quantity: qtyCtrl.text,
                discount: double.tryParse(discountCtrl.text) ?? 0,
                price: double.tryParse(priceCtrl.text) ?? 0,
                seller: state.userEmail ?? 'You',
                distance: '0.0 km',
                sellerId: state.userEmail,
                imageUrl: imageUrl,
                inStock: inStock,
              );
              state.addUserItem(item);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
