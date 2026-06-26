import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/custom_button.dart';
import 'my_listings_screen.dart';
import '../profile/booking_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final l10n = AppLocalizations.of(context)!;

    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'hi', 'name': 'हिंदी'},
      {'code': 'te', 'name': 'తెలుగు'},
      {'code': 'ta', 'name': 'தமிழ்'},
      {'code': 'kn', 'name': 'ಕನ್ನಡ'},
      {'code': 'ml', 'name': 'മലയാളം'},
      {'code': 'bn', 'name': 'বাংলা'},
      {'code': 'gu', 'name': 'ગુજરાતી'},
      {'code': 'mr', 'name': 'मराठी'},
    ];

    final currentLanguage = languages.firstWhere(
      (l) => l['code'] == (state.savedLanguage ?? 'en'),
      orElse: () => languages[0],
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.userEmail != null ? state.userEmail! : 'Farmer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${l10n.buyer} / ${l10n.seller} • ${l10n.renter} / ${l10n.owner}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      if (state.sellerRatingCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${state.sellerRating.toStringAsFixed(1)} (${state.sellerRatingCount})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Selling Mode Toggle (Meesho-like)
        Card(
          color: state.isSellerBanned
              ? Colors.red.shade50
              : state.sellingModeEnabled
              ? Colors.green.shade50
              : Colors.grey.shade50,
          child: ListTile(
            leading: Icon(
              state.isSellerBanned
                  ? Icons.block
                  : state.sellingModeEnabled
                  ? Icons.store
                  : Icons.store_outlined,
              color: state.isSellerBanned
                  ? Colors.red
                  : state.sellingModeEnabled
                  ? Colors.green
                  : Colors.grey,
            ),
            title: Text(
              state.isSellerBanned
                  ? 'Selling Mode: BLOCKED'
                  : state.sellingModeEnabled
                  ? 'Selling Mode: ON'
                  : 'Selling Mode: OFF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: state.isSellerBanned
                    ? Colors.red.shade700
                    : state.sellingModeEnabled
                    ? Colors.green.shade700
                    : Colors.grey.shade700,
              ),
            ),
            subtitle: Text(
              state.isSellerBanned
                  ? 'Low rating: selling is disabled until ratings improve.'
                  : state.sellingModeEnabled
                  ? 'You can add machinery and items to sell'
                  : 'Enable to start selling machinery and items',
            ),
            trailing: Switch(
              value: state.sellingModeEnabled,
              onChanged: state.isSellerBanned
                  ? null
                  : (value) {
                      state.setSellingMode(value);
                      if (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Selling mode enabled! You can now add items and machinery.',
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // My Listings Card
        Card(
          child: ListTile(
            leading: const Icon(Icons.list_alt),
            title: Text(l10n.myListings),
            subtitle: Text(
              '${state.getMyMachines().length} machines • ${state.getMyItems().length} items',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Bookings & Orders Card
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('My Bookings & Orders'),
            subtitle: const Text(
              'Manage your machine bookings and item orders',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookingManagementScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Language Selection
        Card(
          child: ExpansionTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(currentLanguage['name']!),
            children: languages.map((lang) {
              final isSelected = lang['code'] == currentLanguage['code'];
              return ListTile(
                title: Text(lang['name']!),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  state.setLanguage(lang['code']!);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Offline cache'),
            subtitle: Text(
              state.offlineMode
                  ? 'Data cached • works without network'
                  : 'Toggle wifi to simulate offline',
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Support'),
            subtitle: const Text(
              'Local Kisan Mitra desk • Multi-language support',
            ),
          ),
        ),
        const SizedBox(height: 12),
        CustomButton(
          label: l10n.logout,
          icon: Icons.logout,
          onPressed: () async {
            await state.logout();
          },
        ),
      ],
    );
  }
}
