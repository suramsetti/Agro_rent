import 'package:flutter/material.dart';
import '../../models/machine_model.dart';
import '../../services/storage_service.dart';
import '../../app_scope.dart';
import 'machine_detail.dart';

class MachineListWithSearchScreen extends StatefulWidget {
  const MachineListWithSearchScreen({
    super.key,
    this.searchQuery = '',
    this.selectedFilter,
    this.selectedSort,
  });

  final String searchQuery;
  final String? selectedFilter;
  final String? selectedSort;

  @override
  State<MachineListWithSearchScreen> createState() =>
      _MachineListWithSearchScreenState();
}

class _MachineListWithSearchScreenState
    extends State<MachineListWithSearchScreen> {
  String _searchQuery = '';
  String? _selectedFilter;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.searchQuery;
    _selectedFilter = widget.selectedFilter;
    _selectedSort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);

    // Show all available machines for booking
    final allMachines = state.machines;

    // Filter machines based on search and filters
    List<Machine> filteredMachines = _filterMachines(allMachines);

    // Safety check if list is empty
    return Scaffold(
      appBar: AppBar(title: const Text('Machinery for Rental')),
      body: filteredMachines.isEmpty
          ? Center(
              child: Text(
                'No machines found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid: 4 columns for desktop, 2 for tablet, 1 for mobile
                int crossAxisCount;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4; // Desktop
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 2; // Tablet
                } else {
                  crossAxisCount = 1; // Mobile
                }

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredMachines.length,
                    itemBuilder: (context, index) {
                      final machine = filteredMachines[index];
                      return _MachineCard(
                        machine: machine,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MachineDetailScreen(machine: machine),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  List<Machine> _filterMachines(List<Machine> machines) {
    List<Machine> filtered = List.from(machines);

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (machine) =>
                machine.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                machine.owner.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                machine.location.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Category filter
    if (_selectedFilter != null && _selectedFilter != 'All') {
      filtered = filtered
          .where(
            (machine) => machine.name.toLowerCase().contains(
              _selectedFilter!.toLowerCase(),
            ),
          )
          .toList();
    }

    // Sort
    if (_selectedSort != null) {
      switch (_selectedSort) {
        case 'Price: Low to High':
          filtered.sort((a, b) => a.ratePerHour.compareTo(b.ratePerHour));
          break;
        case 'Price: High to Low':
          filtered.sort((a, b) => b.ratePerHour.compareTo(a.ratePerHour));
          break;
        case 'Rating: High to Low':
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Name: A to Z':
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
      }
    }

    return filtered;
  }
}

// --- INTERNAL CARD WIDGET WITH IMAGE LOGIC ---
class _MachineCard extends StatelessWidget {
  const _MachineCard({required this.machine, required this.onTap});

  final Machine machine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- MACHINE IMAGE SECTION ---
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: StorageService.createImageWidget(
                    machine.imageUrl,
                    machineName: machine.name,
                  ),
                ),
              ),
            ),

            // --- DETAILS SECTION ---
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Machine name
                    Text(
                      machine.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Location and rating row
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            machine.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          machine.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${machine.ratePerHour.toStringAsFixed(0)}/hr',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
