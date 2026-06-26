import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app_scope.dart';
import '../../models/item_model.dart';

class ItemDeliveryDetailsScreen extends StatefulWidget {
  const ItemDeliveryDetailsScreen({super.key, required this.item});

  final LeftoverItem item;

  @override
  State<ItemDeliveryDetailsScreen> createState() =>
      _ItemDeliveryDetailsScreenState();
}

class _ItemDeliveryDetailsScreenState extends State<ItemDeliveryDetailsScreen> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  List<LatLng> _deliveryRoute = [];
  LatLng? _currentDeliveryPosition;
  Timer? _deliveryTimer;
  int _routeIndex = 0;
  bool _isDelivering = false;

  @override
  void initState() {
    super.initState();
    _generateDeliveryRoute();
    _startDeliveryTracking();
  }

  @override
  void dispose() {
    _deliveryTimer?.cancel();
    super.dispose();
  }

  void _generateDeliveryRoute() {
    // Demo delivery route from seller to buyer
    _deliveryRoute = [
      const LatLng(18.673, 78.099), // Seller location
      const LatLng(18.680, 78.105), // Waypoint 1
      const LatLng(18.685, 78.110), // Waypoint 2
      const LatLng(18.690, 78.115), // Waypoint 3
      const LatLng(18.695, 78.120), // Waypoint 4
      const LatLng(18.700, 78.125), // Buyer location
    ];

    // Create polyline for the delivery route
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('delivery_route'),
        color: Colors.green,
        width: 4,
        points: _deliveryRoute,
        patterns: [PatternItem.dash(10), PatternItem.gap(5)],
      ),
    );
  }

  void _startDeliveryTracking() {
    setState(() {
      _isDelivering = true;
      _currentDeliveryPosition = _deliveryRoute[0];
    });

    _deliveryTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_routeIndex < _deliveryRoute.length - 1) {
        setState(() {
          _routeIndex++;
          _currentDeliveryPosition = _deliveryRoute[_routeIndex];
        });

        // Animate camera to follow delivery
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentDeliveryPosition!, zoom: 15.0),
            ),
          );
        }
      } else {
        // Delivery complete
        setState(() {
          _isDelivering = false;
        });
        _deliveryTimer?.cancel();
      }
    });
  }

  void _toggleDelivery() {
    if (_isDelivering) {
      _deliveryTimer?.cancel();
      setState(() {
        _isDelivering = false;
      });
    } else {
      _startDeliveryTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);

    // Create markers for seller, buyer, and current delivery position
    final markers = <Marker>{};

    // Add seller marker
    markers.add(
      Marker(
        markerId: const MarkerId('seller'),
        position: const LatLng(18.673, 78.099),
        infoWindow: InfoWindow(
          title: 'Seller Location',
          snippet: widget.item.seller,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Add buyer marker
    markers.add(
      Marker(
        markerId: const MarkerId('buyer'),
        position: const LatLng(18.700, 78.125),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: state.userEmail ?? 'Buyer',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add current delivery position
    if (_currentDeliveryPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: _currentDeliveryPosition!,
          infoWindow: const InfoWindow(
            title: 'Delivery Vehicle',
            snippet: 'Currently delivering your item',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Delivery Tracking'),
        actions: [
          IconButton(
            onPressed: _toggleDelivery,
            icon: Icon(_isDelivering ? Icons.pause : Icons.play_arrow),
            tooltip: _isDelivering ? 'Pause Delivery' : 'Start Delivery',
          ),
          IconButton(
            onPressed: () {
              if (_mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: LatLng(18.673, 78.099),
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
              initialCameraPosition: const CameraPosition(
                target: LatLng(18.673, 78.099),
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

          // Delivery info section
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
                // Item details
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade50,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildMappedImage(widget.item.name),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.item.quantity,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${widget.item.discountedPrice.toStringAsFixed(0)} ₹',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
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
                          color: _isDelivering ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isDelivering ? 'DELIVERING' : 'PAUSED',
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

                // Delivery details
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _buildDeliveryTile(
                        icon: Icons.local_shipping,
                        title: 'Delivery Status',
                        subtitle: _isDelivering
                            ? 'On the way - ${(_routeIndex * 20).toString()}% complete'
                            : 'Delivery paused',
                        color: Colors.green,
                      ),
                      _buildDeliveryTile(
                        icon: Icons.person,
                        title: 'Seller',
                        subtitle: widget.item.seller,
                        color: Colors.blue,
                      ),
                      _buildDeliveryTile(
                        icon: Icons.location_on,
                        title: 'Delivery Address',
                        subtitle: 'Your registered address',
                        color: Colors.red,
                      ),
                      _buildDeliveryTile(
                        icon: Icons.route,
                        title: 'Route Progress',
                        subtitle:
                            '${_routeIndex + 1}/${_deliveryRoute.length} waypoints completed',
                        color: Colors.orange,
                      ),
                      _buildDeliveryTile(
                        icon: Icons.access_time,
                        title: 'Estimated Arrival',
                        subtitle: '${(5 - _routeIndex) * 3} minutes',
                        color: Colors.purple,
                      ),
                      _buildDeliveryTile(
                        icon: Icons.phone,
                        title: 'Contact Delivery',
                        subtitle: '+91 98765 43210',
                        color: Colors.teal,
                      ),
                      _buildDeliveryTile(
                        icon: Icons.payment,
                        title: 'Payment Status',
                        subtitle:
                            'Paid online • ₹${widget.item.discountedPrice.toStringAsFixed(0)}',
                        color: Colors.indigo,
                      ),
                      _buildDeliveryTile(
                        icon: Icons.receipt,
                        title: 'Order ID',
                        subtitle:
                            'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        color: Colors.brown,
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

  Widget _buildDeliveryTile({
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

  Widget _buildMappedImage(String itemName) {
    String assetPath;
    final lowerName = itemName.toLowerCase();

    if (lowerName.contains('urea')) {
      assetPath = 'assets/image_529fe3.jpg';
    } else if (lowerName.contains('dap') || lowerName.contains('diammonium')) {
      assetPath = 'assets/image_529957.jpg';
    } else if (lowerName.contains('potash') || lowerName.contains('muriate')) {
      assetPath = 'assets/image_529c1d.jpg';
    } else {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image, color: Colors.grey)),
      );
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }
}
