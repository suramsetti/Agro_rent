import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../widgets/schemes_carousel.dart';

class SchemeApplicationScreen extends StatelessWidget {
  const SchemeApplicationScreen({super.key, required this.scheme});

  final Scheme scheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${scheme.title} - Application'),
        backgroundColor: scheme.color.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scheme Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.color.withOpacity(0.2),
                    radius: 30,
                    child: Icon(scheme.icon, color: scheme.color, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheme.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          scheme.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (scheme.isRegistrationDeadlineNear())
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Deadline: ${scheme.formattedDeadline}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Application Form
            _ApplicationForm(scheme: scheme),
          ],
        ),
      ),
    );
  }
}

class _ApplicationForm extends StatefulWidget {
  const _ApplicationForm({required this.scheme});

  final Scheme scheme;

  @override
  State<_ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<_ApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landAreaController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _panController = TextEditingController();

  String _selectedState = '';
  String _selectedDistrict = '';
  String _selectedCrop = '';
  bool _termsAccepted = false;
  bool _isLoading = false;

  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  final List<String> _crops = [
    'Rice',
    'Wheat',
    'Cotton',
    'Sugarcane',
    'Pulses',
    'Oilseeds',
    'Vegetables',
    'Fruits',
    'Spices',
    'Floriculture',
    'Medicinal Plants',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landAreaController.dispose();
    _aadhaarController.dispose();
    _bankAccountController.dispose();
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Section
          _buildSectionHeader('Personal Information'),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name as per Aadhaar',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),

          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email address',
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

          _buildTextField(
            controller: _phoneController,
            label: 'Mobile Number',
            hint: 'Enter your 10-digit mobile number',
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your mobile number';
              }
              if (value.length != 10) {
                return 'Please enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),

          _buildTextField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter your complete address',
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Location Information Section
          _buildSectionHeader('Location Information'),
          const SizedBox(height: 16),

          _buildDropdownField(
            value: _selectedState,
            label: 'State',
            items: _states,
            onChanged: (value) {
              setState(() {
                _selectedState = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your state';
              }
              return null;
            },
          ),

          _buildTextField(
            controller: TextEditingController(text: _selectedDistrict),
            label: 'District',
            hint: 'Enter your district',
            onChanged: (String? value) {
              setState(() {
                _selectedDistrict = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your district';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Farm Information Section
          _buildSectionHeader('Farm Information'),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _landAreaController,
            label: 'Land Area (in acres)',
            hint: 'Enter your total land area',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your land area';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),

          _buildDropdownField(
            value: _selectedCrop,
            label: 'Primary Crop',
            items: _crops,
            onChanged: (value) {
              setState(() {
                _selectedCrop = value!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your primary crop';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Document Information Section
          _buildSectionHeader('Document Information'),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _aadhaarController,
            label: 'Aadhaar Number',
            hint: 'Enter your 12-digit Aadhaar number',
            maxLength: 12,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your Aadhaar number';
              }
              if (value.length != 12) {
                return 'Please enter a valid 12-digit Aadhaar number';
              }
              return null;
            },
          ),

          _buildTextField(
            controller: _bankAccountController,
            label: 'Bank Account Number',
            hint: 'Enter your bank account number',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your bank account number';
              }
              return null;
            },
          ),

          _buildTextField(
            controller: _panController,
            label: 'PAN Number (Optional)',
            hint: 'Enter your PAN number if available',
          ),

          const SizedBox(height: 24),

          // Terms and Conditions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terms and Conditions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• I certify that all information provided is true and correct\n'
                  '• I agree to the terms and conditions of the scheme\n'
                  '• I authorize verification of provided documents\n'
                  '• I understand that false information may lead to rejection',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I accept the terms and conditions',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _termsAccepted && !_isLoading
                  ? _submitApplication
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.scheme.color,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Submitting...'),
                      ],
                    )
                  : const Text(
                      'Submit Application',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: (value == null || value.isEmpty) ? null : value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: (String? value) {
          onChanged(value);
        },
        validator: validator,
      ),
    );
  }

  void _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your application has been successfully submitted.'),
            const SizedBox(height: 8),
            Text('Application ID: APP${DateTime.now().millisecondsSinceEpoch}'),
            const SizedBox(height: 8),
            const Text('You will receive a confirmation message shortly.'),
            const SizedBox(height: 8),
            Text('Scheme: ${widget.scheme.title}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
