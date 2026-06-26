import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/driver_model.dart';
import '../../widgets/custom_button.dart';
import 'driver_detail_screen.dart';

class DriverListScreen extends StatelessWidget {
  const DriverListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    
    // Show all available drivers for booking
    final allDrivers = state.drivers;
    
    // Safety check if list is empty
    if (allDrivers.isEmpty) {
      return const Center(child: Text('No drivers available for booking.'));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Available Drivers for Booking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Generates the list of all available driver cards
        ...allDrivers.map(
          (driver) => _DriverCard(
            driver: driver,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DriverDetailScreen(driver: driver),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- INTERNAL DRIVER CARD WIDGET ---
class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.driver,
    required this.onTap,
  });

  final Driver driver;
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green[100],
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              driver.phone,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.email, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              driver.email,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${driver.ratePerHour.toStringAsFixed(0)} ₹ / hr',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Rating and Experience
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        driver.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(Icons.work, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${driver.experience} years',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: driver.isAvailable ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      driver.isAvailable ? 'Available' : 'Busy',
                      style: TextStyle(
                        fontSize: 12,
                        color: driver.isAvailable ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Vehicle Type and Certifications
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.agriculture, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Vehicle: ${driver.vehicleType}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Certifications:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: driver.certifiedFor.map((cert) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cert,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Action Button
              CustomButton(
                label: 'Book Driver',
                onPressed: driver.isAvailable ? onTap : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
