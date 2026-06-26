import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tracking Feature',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Live tracking will be available soon',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
