import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({
    super.key,
    required this.onSearch,
    this.hintText = 'Search...',
    this.filterOptions,
    this.onFilterChanged,
    this.sortOptions,
    this.onSortChanged,
  });

  final Function(String) onSearch;
  final String hintText;
  final List<String>? filterOptions;
  final Function(String?)? onFilterChanged;
  final List<String>? sortOptions;
  final Function(String?)? onSortChanged;

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;
  String? _selectedSort;
  bool _isExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar with expand/collapse button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  onChanged: widget.onSearch,
                ),
              ),
              if (widget.filterOptions != null || widget.sortOptions != null)
                const SizedBox(width: 8),
              if (widget.filterOptions != null || widget.sortOptions != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  tooltip: 'Filter & Sort',
                ),
            ],
          ),

          // Expanded filter and sort options
          if (_isExpanded) ...[
            const SizedBox(height: 16),

            // Filter options
            if (widget.filterOptions != null) ...[
              Row(
                children: [
                  const Icon(Icons.filter_list, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter,
                      decoration: InputDecoration(
                        labelText: 'Filter',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All')),
                        ...widget.filterOptions!.map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value;
                        });
                        widget.onFilterChanged?.call(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Sort options
            if (widget.sortOptions != null) ...[
              Row(
                children: [
                  const Icon(Icons.sort, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: InputDecoration(
                        labelText: 'Sort by',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Default'),
                        ),
                        ...widget.sortOptions!.map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value;
                        });
                        widget.onSortChanged?.call(value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// Advanced search widget for more complex searches
class AdvancedSearchWidget extends StatefulWidget {
  const AdvancedSearchWidget({
    super.key,
    required this.onSearch,
    this.priceRange,
    this.onPriceRangeChanged,
    this.ratingRange,
    this.onRatingRangeChanged,
    this.distanceRange,
    this.onDistanceRangeChanged,
    this.maxPrice = 1000,
    this.maxRating = 5,
    this.maxDistance = 50,
  });

  final Function(Map<String, dynamic>) onSearch;
  final RangeValues? priceRange;
  final Function(RangeValues)? onPriceRangeChanged;
  final RangeValues? ratingRange;
  final Function(RangeValues)? onRatingRangeChanged;
  final RangeValues? distanceRange;
  final Function(RangeValues)? onDistanceRangeChanged;
  final double maxPrice;
  final double maxRating;
  final double maxDistance;

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Toggle button for advanced search
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                label: Text(_isExpanded ? 'Simple Search' : 'Advanced Search'),
              ),
            ],
          ),

          // Advanced search options
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Price range slider
                  if (widget.onPriceRangeChanged != null) ...[
                    const Text('Price Range'),
                    RangeSlider(
                      values:
                          widget.priceRange ?? RangeValues(0, widget.maxPrice),
                      min: 0,
                      max: widget.maxPrice,
                      divisions: 20,
                      labels: RangeLabels(
                        '${(widget.priceRange?.start ?? 0).toInt()} ₹',
                        '${(widget.priceRange?.end ?? widget.maxPrice).toInt()} ₹',
                      ),
                      onChanged: widget.onPriceRangeChanged,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Rating range slider
                  if (widget.onRatingRangeChanged != null) ...[
                    const Text('Rating'),
                    RangeSlider(
                      values:
                          widget.ratingRange ??
                          RangeValues(0, widget.maxRating),
                      min: 0,
                      max: widget.maxRating,
                      divisions: 10,
                      labels: RangeLabels(
                        (widget.ratingRange?.start ?? 0).toStringAsFixed(1),
                        (widget.ratingRange?.end ?? widget.maxRating)
                            .toStringAsFixed(1),
                      ),
                      onChanged: widget.onRatingRangeChanged,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Distance range slider
                  if (widget.onDistanceRangeChanged != null) ...[
                    const Text('Distance (km)'),
                    RangeSlider(
                      values:
                          widget.distanceRange ??
                          RangeValues(0, widget.maxDistance),
                      min: 0,
                      max: widget.maxDistance,
                      divisions: 10,
                      labels: RangeLabels(
                        '${(widget.distanceRange?.start ?? 0).toInt()} km',
                        '${(widget.distanceRange?.end ?? widget.maxDistance).toInt()} km',
                      ),
                      onChanged: widget.onDistanceRangeChanged,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
