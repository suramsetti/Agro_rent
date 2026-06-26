import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

import '../../app_scope.dart';
import '../../l10n/app_localizations.dart';
import '../../models/machine_model.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';

class AddMachineScreen extends StatefulWidget {
  const AddMachineScreen({super.key});

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  final nameCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final _storage = StorageService();
  String? imageBase64;
  bool uploadingImage = false;
  String? selectedImagePath; // Store the actual selected image path

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final l10n = AppLocalizations.of(context)!;

    // Check if selling mode is enabled
    if (!state.sellingModeEnabled) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addMachine)),
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
                  'Please enable selling mode from your profile to add machinery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to profile tab
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
        appBar: AppBar(title: Text(l10n.addMachine)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Selling disabled',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
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
      appBar: AppBar(title: Text(l10n.addMachine)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Machine name',
              border: OutlineInputBorder(),
              hintText: 'e.g., Mahindra 575',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: rateCtrl,
            decoration: const InputDecoration(
              labelText: 'Rate per hour (₹)',
              border: OutlineInputBorder(),
              hintText: 'e.g., 600',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: locationCtrl,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
              hintText: 'e.g., 2.1 km • Nizamabad Road',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionCtrl,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: uploadingImage
                    ? null
                    : () async {
                        setState(() => uploadingImage = true);
                        final result = await _storage.pickAndUpload(folder: 'machines');
                        if (mounted) {
                          setState(() {
                            imageBase64 = result['base64'];
                            selectedImagePath = result['localPath'];
                            uploadingImage = false;
                          });
                          if (result['base64'] != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image stored successfully'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image selection cancelled'),
                                backgroundColor: Colors.grey,
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
              if (imageBase64 != null)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          // Image preview section
          if (selectedImagePath != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageBase64 != null
                    ? _storage.imageFromBase64String(imageBase64!)
                    : Image.file(
                        File(selectedImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Preview not available', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'List Machine',
            onPressed: () {
              if (nameCtrl.text.isEmpty || rateCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              final machine = Machine(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text,
                ratePerHour: double.tryParse(rateCtrl.text) ?? 0,
                location: locationCtrl.text.isEmpty
                    ? 'Location not specified'
                    : locationCtrl.text,
                owner: state.userEmail ?? 'You',
                rating: 0.0, // New listing, no ratings yet
                position: const LatLng(18.673, 78.099), // Default position
                ownerId: state.userEmail,
                description: descriptionCtrl.text.isEmpty
                    ? null
                    : descriptionCtrl.text,
                imageUrl: imageBase64, // Store base64 string in database
              );

              state.addUserMachine(machine);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Machine listed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    rateCtrl.dispose();
    locationCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }
}

