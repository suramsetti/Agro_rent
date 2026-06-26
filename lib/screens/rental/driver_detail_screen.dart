import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/driver_model.dart';
import '../../widgets/custom_button.dart';

class DriverDetailScreen extends StatefulWidget {
  final Driver driver;

  const DriverDetailScreen({super.key, required this.driver});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.driver.name),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Profile Header
            _buildDriverProfile(),
            const SizedBox(height: 24),

            // Contact Information
            _buildSectionTitle('Contact Information'),
            _buildContactInfo(),
            const SizedBox(height: 24),

            // Professional Details
            _buildSectionTitle('Professional Details'),
            _buildProfessionalInfo(),
            const SizedBox(height: 24),

            // Certifications
            _buildSectionTitle('Vehicle Certifications'),
            _buildCertifications(),
            const SizedBox(height: 24),

            // Service Location
            _buildSectionTitle('Service Location'),
            _buildLocationMap(),
            const SizedBox(height: 24),

            // License Information
            _buildSectionTitle('License Information'),
            _buildLicenseInfo(),
            const SizedBox(height: 32),

            // Booking Button
            if (widget.driver.isAvailable)
              CustomButton(
                label: 'Book Driver',
                onPressed: _isBooking ? null : _bookDriver,
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Driver Currently Unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverProfile() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isMobile ? 30 : 40,
                  backgroundColor: Colors.green[100],
                  child: Icon(
                    Icons.person,
                    size: isMobile ? 30 : 40,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driver.name,
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 6 : 8,
                                vertical: isMobile ? 2 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${widget.driver.ratePerHour.toStringAsFixed(0)} ₹ / hr',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.driver.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      Wrap(
                        spacing: isMobile ? 8 : 16,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.work,
                                size: isMobile ? 14 : 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${widget.driver.experience} years',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: isMobile ? 14 : 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${widget.driver.totalTrips} trips',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!isMobile)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.driver.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.phone, 'Phone', widget.driver.phone),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', widget.driver.email),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.agriculture,
              'Primary Vehicle',
              widget.driver.vehicleType,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.speed,
              'Rate per Hour',
              '${widget.driver.ratePerHour} ₹',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.work, 'Experience', widget.driver.experience),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.trending_up,
              'Total Trips',
              '${widget.driver.totalTrips}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertifications() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Certified to operate:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.driver.certifiedFor.map((cert) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    cert,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMap() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Area:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.driver.position,
                  zoom: 13,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(widget.driver.id),
                    position: widget.driver.position,
                    infoWindow: InfoWindow(
                      title: widget.driver.name,
                      snippet: 'Service Area',
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.driver.licenseNumber != null) ...[
              _buildInfoRow(
                Icons.credit_card,
                'License Number',
                widget.driver.licenseNumber!,
              ),
              const SizedBox(height: 12),
            ],
            if (widget.driver.licenseExpiry != null)
              _buildInfoRow(
                Icons.calendar_today,
                'License Expiry',
                widget.driver.licenseExpiry!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  void _bookDriver() async {
    setState(() {
      _isBooking = true;
    });

    try {
      // Create booking logic here
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate booking process

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }
}
