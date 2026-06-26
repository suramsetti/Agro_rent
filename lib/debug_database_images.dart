import 'dart:convert';
import 'package:flutter/material.dart';
import 'app_scope.dart';

// Debug screen to view images stored in database
class DatabaseImagesDebugScreen extends StatelessWidget {
  const DatabaseImagesDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final userMachines = state.getMyMachines();
    final userItems = state.getMyItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Images Debug'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'User Machines with Images:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...userMachines.map((machine) => _MachineDebugCard(machine: machine)),
          const SizedBox(height: 32),
          const Text(
            'User Items with Images:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...userItems.map((item) => _ItemDebugCard(item: item)),
        ],
      ),
    );
  }
}

class _MachineDebugCard extends StatelessWidget {
  final machine;

  const _MachineDebugCard({required this.machine});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              machine.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('ID: ${machine.id}'),
            Text('Owner: ${machine.owner}'),
            const SizedBox(height: 8),
            const Text(
              'Image Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (machine.imageUrl != null && machine.imageUrl!.isNotEmpty) ...[
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildImagePreview(machine.imageUrl!),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type: ${_getImageType(machine.imageUrl!)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Length: ${machine.imageUrl!.length} characters',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (machine.imageUrl!.length > 100)
                      Text(
                        'Preview: ${machine.imageUrl!.substring(0, 100)}...',
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      )
                    else
                      Text(
                        'Full: ${machine.imageUrl!}',
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                  ],
                ),
              ),
            ] else ...[
              const Text('No image stored', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemDebugCard extends StatelessWidget {
  final item;

  const _ItemDebugCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('ID: ${item.id}'),
            Text('Seller: ${item.seller}'),
            const SizedBox(height: 8),
            const Text(
              'Image Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildImagePreview(item.imageUrl!),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type: ${_getImageType(item.imageUrl!)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Length: ${item.imageUrl!.length} characters',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (item.imageUrl!.length > 100)
                      Text(
                        'Preview: ${item.imageUrl!.substring(0, 100)}...',
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      )
                    else
                      Text(
                        'Full: ${item.imageUrl!}',
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                  ],
                ),
              ),
            ] else ...[
              const Text('No image stored', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildImageWidget(String imageUrl) {
  if (imageUrl.startsWith('data:image')) {
    // Base64 image
    final base64String = imageUrl.split(',')[1];
    try {
      final imageBytes = base64Decode(base64String);
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } catch (e) {
      return const Center(
        child: Icon(Icons.error, color: Colors.red),
      );
    }
  } else if (imageUrl.startsWith('assets/')) {
    // Asset image
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  } else if (imageUrl.startsWith('http')) {
    // Network image
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  } else {
    // Try as base64 without data URI prefix
    try {
      final imageBytes = base64Decode(imageUrl);
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } catch (e) {
      return const Center(
        child: Icon(Icons.error, color: Colors.red),
      );
    }
  }
}

Widget _buildImagePreview(String imageUrl) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: _buildImageWidget(imageUrl),
  );
}

String _getImageType(String imageUrl) {
  if (imageUrl.startsWith('data:image')) {
    return 'Base64 (Data URI)';
  } else if (imageUrl.startsWith('assets/')) {
    return 'Asset';
  } else if (imageUrl.startsWith('http')) {
    return 'Network URL';
  } else if (imageUrl.length > 100 && !imageUrl.startsWith('http')) {
    return 'Base64 (Raw)';
  } else {
    return 'Unknown';
  }
}
