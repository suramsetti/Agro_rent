import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app_scope.dart';
import '../../models/driver_model.dart';
import '../../widgets/custom_button.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final vehicleTypeCtrl = TextEditingController();
  final licenseNumberCtrl = TextEditingController();
  final licenseExpiryCtrl = TextEditingController();

  LatLng _selectedLocation = const LatLng(18.673, 78.099); // Default location
  double _rating = 5.0;
  final List<String> _certifiedFor = [];
  bool _isLoading = false;

  final List<String> _vehicleTypes = [
    'Tractor',
    'Harvester',
    'Drone',
    'Sprayer',
    'Plow',
    'Seeder',
    'Thresher',
    'Truck',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Register as a Driver',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in your details to start accepting bookings',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Personal Information
              _buildSectionTitle('Personal Information'),
              _buildTextField(
                controller: nameCtrl,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: phoneCtrl,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: emailCtrl,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Professional Information
              _buildSectionTitle('Professional Information'),
              _buildTextField(
                controller: rateCtrl,
                label: 'Rate per Hour (₹)',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate <= 0) {
                    return 'Please enter a valid rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: experienceCtrl,
                label: 'Experience (years)',
                icon: Icons.work,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your experience';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: vehicleTypeCtrl.text.isEmpty
                    ? null
                    : vehicleTypeCtrl.text,
                decoration: InputDecoration(
                  labelText: 'Primary Vehicle Type',
                  prefixIcon: const Icon(Icons.agriculture),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _vehicleTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    vehicleTypeCtrl.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your vehicle type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // License Information
              _buildSectionTitle('License Information'),
              _buildTextField(
                controller: licenseNumberCtrl,
                label: 'License Number',
                icon: Icons.credit_card,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your license number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: licenseExpiryCtrl,
                label: 'License Expiry Date',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter license expiry date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Certifications
              _buildSectionTitle('Vehicle Certifications'),
              const Text(
                'Select vehicles you are certified to operate:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _vehicleTypes.map((vehicle) {
                  final isSelected = _certifiedFor.contains(vehicle);
                  return FilterChip(
                    label: Text(vehicle),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _certifiedFor.add(vehicle);
                        } else {
                          _certifiedFor.remove(vehicle);
                        }
                      });
                    },
                    backgroundColor: isSelected
                        ? Colors.green[100]
                        : Colors.grey[200],
                    selectedColor: Colors.green,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Rating
              _buildSectionTitle('Initial Rating'),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.green,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: Colors.green,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rating'),
                        Text('${_rating.toStringAsFixed(1)} ⭐'),
                      ],
                    ),
                    Slider(
                      value: _rating,
                      min: 1.0,
                      max: 5.0,
                      divisions: 40,
                      onChanged: (value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Location
              _buildSectionTitle('Service Location'),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 13,
                  ),
                  onTap: (location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedLocation,
                      infoWindow: const InfoWindow(title: 'Your Service Area'),
                    ),
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                label: 'Register as Driver',
                onPressed: _isLoading ? null : _registerDriver,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }

  void _registerDriver() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_certifiedFor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one vehicle certification'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final state = AppScope.state(context);
      final driver = Driver(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        ratePerHour: double.parse(rateCtrl.text),
        certifiedFor: _certifiedFor,
        rating: _rating,
        position: _selectedLocation,
        experience: experienceCtrl.text.trim(),
        vehicleType: vehicleTypeCtrl.text.trim(),
        licenseNumber: licenseNumberCtrl.text.trim(),
        licenseExpiry: licenseExpiryCtrl.text.trim(),
        registeredAt: DateTime.now(),
      );

      state.addDriver(driver);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
