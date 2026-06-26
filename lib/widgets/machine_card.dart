import 'package:flutter/material.dart';

import '../models/machine_model.dart';
import 'driver_badge.dart';

class MachineCard extends StatelessWidget {
  const MachineCard({
    super.key,
    required this.machine,
    required this.onBook,
  });

  final Machine machine;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  machine.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(machine.rating.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${machine.ratePerHour} ₹/hr • Owner: ${machine.owner}'),
            Text(machine.location),
            const SizedBox(height: 8),
            const DriverBadge(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onBook,
                child: const Text('Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

