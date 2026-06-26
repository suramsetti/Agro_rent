import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app_scope.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  List<LatLng> _demoRoute = [];
  LatLng? _currentDriverPosition;
  Timer? _trackingTimer;
  int _routeIndex = 0;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _generateDemoRoute();
    _startDemoTracking();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _generateDemoRoute() {
    // Demo route from starting point to machine location
    _demoRoute = [
      const LatLng(18.673, 78.099), // Start point
      const LatLng(18.680, 78.105), // Waypoint 1
      const LatLng(18.685, 78.110), // Waypoint 2
      const LatLng(18.690, 78.115), // Waypoint 3
      const LatLng(18.695, 78.120), // Waypoint 4
      const LatLng(18.700, 78.125), // Waypoint 5
      const LatLng(18.673, 78.099), // End point (machine location)
    ];

    // Create polyline for the route
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('demo_route'),
        color: Colors.blue,
        width: 4,
        points: _demoRoute,
        patterns: [PatternItem.dash(10), PatternItem.gap(5)],
      ),
    );
  }

  void _startDemoTracking() {
    setState(() {
      _isTracking = true;
      _currentDriverPosition = _demoRoute[0];
    });

    _trackingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_routeIndex < _demoRoute.length - 1) {
        setState(() {
          _routeIndex++;
          _currentDriverPosition = _demoRoute[_routeIndex];
        });

        // Animate camera to follow driver
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentDriverPosition!, zoom: 15.0),
            ),
          );
        }
      } else {
        // Reset tracking
        setState(() {
          _routeIndex = 0;
          _currentDriverPosition = _demoRoute[0];
        });
      }
    });
  }

  void _toggleTracking() {
    if (_isTracking) {
      _trackingTimer?.cancel();
      setState(() {
        _isTracking = false;
      });
    } else {
      _startDemoTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);

    // Create markers for machines, drivers, and current tracking position
    final markers = <Marker>{};

    // Add machine markers
    markers.addAll(
      state.machines.map(
        (m) => Marker(
          markerId: MarkerId('m-${m.id}'),
          position: m.position,
          infoWindow: InfoWindow(
            title: m.name,
            snippet: 'Owner: ${m.owner} • Rate: ₹${m.ratePerHour}/hr',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      ),
    );

    // Add driver markers
    markers.addAll(
      state.drivers.map(
        (d) => Marker(
          markerId: MarkerId('d-${d.id}'),
          position: d.position,
          infoWindow: InfoWindow(
            title: d.name,
            snippet: 'Rate: ₹${d.ratePerHour}/hr • ${d.experience}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      ),
    );

    // Add current tracking position
    if (_currentDriverPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('tracking_driver'),
          position: _currentDriverPosition!,
          infoWindow: const InfoWindow(
            title: 'Driver on Route',
            snippet: 'Currently delivering machinery',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        actions: [
          IconButton(
            onPressed: _toggleTracking,
            icon: Icon(_isTracking ? Icons.pause : Icons.play_arrow),
            tooltip: _isTracking ? 'Pause Tracking' : 'Start Tracking',
          ),
          IconButton(
            onPressed: () {
              if (_mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: state.machines.isNotEmpty
                          ? state.machines.first.position
                          : const LatLng(18.673, 78.099),
                      zoom: 11.5,
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Reset View',
          ),
        ],
      ),
      body: Column(
        children: [
          // Map section
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: state.machines.isNotEmpty
                    ? state.machines.first.position
                    : const LatLng(18.673, 78.099),
                zoom: 11.5,
              ),
              markers: markers,
              polylines: _polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),

          // Tracking info section
          Container(
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
                // Live tracking status
                Container(
                  padding: const EdgeInsets.all(16),
                  color: _isTracking
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  child: Row(
                    children: [
                      Icon(
                        _isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                        color: _isTracking ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isTracking
                                  ? 'Live Tracking Active'
                                  : 'Tracking Paused',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isTracking ? Colors.green : Colors.grey,
                              ),
                            ),
                            Text(
                              _isTracking
                                  ? 'Driver is ${(_routeIndex * 20).toString()}% through route'
                                  : 'Tap play button to start tracking',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isTracking
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isTracking ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isTracking ? 'LIVE' : 'PAUSED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tracking details
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _buildTrackingTile(
                        icon: Icons.person,
                        title: 'Driver Assigned',
                        subtitle: 'Mahesh • 5 years experience',
                        color: Colors.blue,
                      ),
                      _buildTrackingTile(
                        icon: Icons.agriculture,
                        title: 'Equipment',
                        subtitle: 'Mahindra 575 • Tractor',
                        color: Colors.red,
                      ),
                      _buildTrackingTile(
                        icon: Icons.route,
                        title: 'Route Progress',
                        subtitle:
                            '${_routeIndex + 1}/${_demoRoute.length} waypoints completed',
                        color: Colors.green,
                      ),
                      _buildTrackingTile(
                        icon: Icons.access_time,
                        title: 'Estimated Arrival',
                        subtitle: '${(5 - _routeIndex) * 5} minutes',
                        color: Colors.orange,
                      ),
                      _buildTrackingTile(
                        icon: Icons.phone,
                        title: 'Contact Driver',
                        subtitle: '+91 98765 43210',
                        color: Colors.purple,
                      ),
                      _buildTrackingTile(
                        icon: Icons.security,
                        title: 'Verification Method',
                        subtitle: 'QR code verification on arrival',
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
    );
  }
}
