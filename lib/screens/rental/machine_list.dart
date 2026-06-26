import 'package:flutter/material.dart';
import '../../models/machine_model.dart';
import '../../services/storage_service.dart';
import '../../app_scope.dart';
import 'machine_detail.dart';

class MachineListScreen extends StatelessWidget {
  const MachineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);

    // Show all available machines for booking
    final allMachines = state.machines;

    // Safety check if list is empty
    if (allMachines.isEmpty) {
      return const Center(child: Text('No machines available for booking.'));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Available Machinery for Booking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Generates the list of all available machine cards
        ...allMachines.map(
          (machine) => _MachineCard(
            machine: machine,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MachineDetailScreen(machine: machine),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- INTERNAL CARD WIDGET WITH IMAGE LOGIC ---
class _MachineCard extends StatelessWidget {
  const _MachineCard({required this.machine, required this.onTap});

  final Machine machine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- MACHINE IMAGE SECTION ---
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                // Helper function to load your specific assets
                child: StorageService.createImageWidget(
                  machine.imageUrl,
                  machineName: machine.name,
                ),
              ),
            ),

            // --- DETAILS SECTION ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          machine.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${machine.ratePerHour.toStringAsFixed(0)} ₹ / hr',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        machine.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        machine.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER: MAPPING NAMES TO YOUR UPLOADED PHOTOS ---
Widget _buildMachineImage(String machineName) {
  String assetPath;
  final lowerName = machineName.toLowerCase();

  if (lowerName.contains('drone')) {
    assetPath = 'assets/images_drone.jpg';
  } else if (lowerName.contains('john') ||
      lowerName.contains('deere') ||
      lowerName.contains('5050')) {
    assetPath = 'assets/images_johndeere5050D.jpg';
  } else if (lowerName.contains('mahindra') || lowerName.contains('yuvo')) {
    assetPath = 'assets/images_mahindra.jpg';
  } else {
    // Default fallback
    assetPath = 'assets/images_mahindra.jpg';
  }

  return Image.asset(
    assetPath,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.agriculture, size: 50, color: Colors.grey),
        ),
      );
    },
  );
}
