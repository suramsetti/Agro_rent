import 'package:flutter/material.dart';
import 'dart:async';

class GovernmentScheme {
  final String id;
  final String title;
  final String description;
  final String benefits;
  final String eligibility;
  final String documents;
  final String applicationProcess;
  final String deadline;
  final String imageUrl;

  GovernmentScheme({
    required this.id,
    required this.title,
    required this.description,
    required this.benefits,
    required this.eligibility,
    required this.documents,
    required this.applicationProcess,
    required this.deadline,
    required this.imageUrl,
  });
}

class SchemesCarousel extends StatefulWidget {
  const SchemesCarousel({super.key});

  @override
  State<SchemesCarousel> createState() => _SchemesCarouselState();
}

class _SchemesCarouselState extends State<SchemesCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<GovernmentScheme> _schemes = [
    GovernmentScheme(
      id: 'pmkisan',
      title: 'PM Kisan Samman Nidhi',
      description:
          'Direct income support of ₹6,000 per year to small and marginal farmers.',
      benefits:
          '• ₹6,000 per year in three equal installments\n• Direct benefit transfer\n• No application required for existing beneficiaries',
      eligibility:
          '• Small and marginal farmers\n• Landholding up to 2 hectares\n• Valid Aadhaar and bank account',
      documents:
          '• Aadhaar card\n• Land records\n• Bank account details\n• Mobile number',
      applicationProcess:
          '1. Register at nearest CSC center\n2. Submit land and identity documents\n3. Verification by authorities\n4. Direct credit to bank account',
      deadline: '31st March 2024',
      imageUrl: 'assets/images_mahindra.jpg',
    ),
    GovernmentScheme(
      id: 'kcc',
      title: 'Kisan Credit Card (KCC)',
      description:
          'Credit facility for farmers to meet agricultural expenses and cultivation needs.',
      benefits:
          '• Up to ₹3 lakh credit limit\n• Interest subvention of 2%\n• Flexible repayment options\n• Crop insurance coverage',
      eligibility:
          '• All farmers including sharecroppers\n• Valid identity proof\n• Land ownership or cultivation records',
      documents:
          '• Identity proof (Aadhaar/Voter ID)\n• Land records\n• Bank account details\n• Photographs',
      applicationProcess:
          '1. Apply at nearest bank branch\n2. Submit required documents\n3. Credit assessment by bank\n4. Card issuance within 15 days',
      deadline: 'Ongoing (No deadline)',
      imageUrl: 'assets/images_johndeere5050D.jpg',
    ),
    GovernmentScheme(
      id: 'pmkmy',
      title: 'Pradhan Mantri Kisan Maandhan Yojana',
      description:
          'Pension scheme for small and marginal farmers providing monthly pension of ₹3,000.',
      benefits:
          '• ₹3,000 monthly pension after 60 years\n• 50% contribution by government\n• Family pension benefits\n• Voluntary scheme',
      eligibility:
          '• Small and marginal farmers\n• Age 18-40 years\n• Landholding up to 2 hectares\n• Not covered under other pension schemes',
      documents:
          '• Aadhaar card\n• Land records\n• Bank account details\n• Age proof',
      applicationProcess:
          '1. Register at Common Service Center\n2. Submit KYC and land documents\n3. Monthly contribution setup\n4. Pension card issuance',
      deadline: 'Ongoing (No deadline)',
      imageUrl: 'assets/images_drone.jpg',
    ),
    GovernmentScheme(
      id: 'nfsa',
      title: 'National Food Security Act',
      description:
          'Food security program providing subsidized food grains to eligible households.',
      benefits:
          '• 5kg food grains per person per month\n• Wheat at ₹2/kg, Rice at ₹3/kg\n• Coarse grains at ₹1/kg\n• Antyodaya Anna Yojana for poorest',
      eligibility:
          '• Priority households (75% rural, 50% urban)\n• Antyodaya households (40% of priority)\n• BPL families\n• Valid ration card',
      documents:
          '• Ration card\n• Aadhaar card\n• Income certificate\n• Residence proof',
      applicationProcess:
          '1. Apply at nearest PDS office\n2. Submit income and identity documents\n3. Verification by authorities\n4. Ration card issuance',
      deadline: 'Ongoing (No deadline)',
      imageUrl: 'assets/image_529957.jpg',
    ),
    GovernmentScheme(
      id: 'soilhealth',
      title: 'Soil Health Card Scheme',
      description:
          'Providing soil health cards to farmers for balanced nutrient application.',
      benefits:
          '• Free soil testing\n• Personalized nutrient recommendations\n• Increased crop productivity\n• Reduced fertilizer costs',
      eligibility:
          '• All farmers\n• Land ownership proof\n• Agricultural land registration',
      documents:
          '• Land records\n• Identity proof\n• Address proof\n• Mobile number',
      applicationProcess:
          '1. Visit nearest agriculture office\n2. Submit land documents\n3. Soil sample collection\n4. Card issuance within 30 days',
      deadline: '31st December 2024',
      imageUrl: 'assets/image_529c1d.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _schemes.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.agriculture, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Government Schemes Available for Farmers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Navigate to all schemes page (if implemented)
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Scrollable Cards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _schemes.length,
              itemBuilder: (context, index) {
                final scheme = _schemes[index];
                return _buildSchemeCard(scheme, index);
              },
            ),
          ),

          // Page Indicator
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _schemes.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.green
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(GovernmentScheme scheme, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scheme Title
            Text(
              scheme.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Description
            Expanded(
              child: Text(
                scheme.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Deadline with blink effect if urgent
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: _isUrgentDeadline(scheme.deadline)
                      ? Colors.red
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Deadline: ${scheme.deadline}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isUrgentDeadline(scheme.deadline)
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            // Apply Button
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showSchemeDetails(context, scheme),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isUrgentDeadline(String deadline) {
    // Check if deadline is within 30 days (simplified check)
    return deadline.contains('2024') && !deadline.contains('Ongoing');
  }

  void _showSchemeDetails(BuildContext context, GovernmentScheme scheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(scheme.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(scheme.description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              const Text(
                'Key Benefits:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(scheme.benefits),
              const SizedBox(height: 12),
              const Text(
                'Eligibility Criteria:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(scheme.eligibility),
              const SizedBox(height: 12),
              const Text(
                'Documents Required:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(scheme.documents),
              const SizedBox(height: 12),
              const Text(
                'How to Apply:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(scheme.applicationProcess),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to scheme application (placeholder)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scheme application feature coming soon!'),
                ),
              );
            },
            child: const Text('Apply Online'),
          ),
        ],
      ),
    );
  }
}
