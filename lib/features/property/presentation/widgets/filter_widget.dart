import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_event.dart';
import '../bloc/property_state.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(PropertyFilter) onApplyFilter;

  const FilterBottomSheet({
    Key? key,
    required this.onApplyFilter,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  String? _selectedLocation;
  String? _selectedStatus;
  List<String> _selectedTags = [];
  List<String> _allLocations = [];
  List<String> _allTags = [];

  @override
  void initState() {
    super.initState();
    _minPrice = 0;
    _maxPrice = 1000000;
    _allLocations = cities;
    _allTags = tags;


  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusXL),
              topRight: Radius.circular(AppTheme.radiusXL),
            ),
          ),
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = 0;
                              _maxPrice = 1000000;
                              _selectedLocation = null;
                              _selectedStatus = null;
                              _selectedTags = [];
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _buildSectionTitle('Price Range', context),
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: 1000000,
                        divisions: 100,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        labels: RangeLabels(
                          '\$${_minPrice.toStringAsFixed(0)}',
                          '\$${_maxPrice.toStringAsFixed(0)}',
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      _buildSectionTitle('Location', context),
                      DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Select location'),
                        value: _selectedLocation,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Locations'),
                          ),
                          ..._allLocations
                              .map((loc) => DropdownMenuItem(
                            value: loc,
                            child: Text(loc),
                          ))
                              .toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedLocation = value);
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      _buildSectionTitle('Status', context),
                      Wrap(
                        spacing: AppTheme.spacing8,
                        children: ['Available', 'Sold', 'Upcoming']
                            .map((status) => FilterChip(
                          label: Text(status),
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus =
                              selected ? status : null;
                            });
                          },
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      _buildSectionTitle('Tags', context),
                      Wrap(
                        spacing: AppTheme.spacing8,
                        runSpacing: AppTheme.spacing8,
                        children: _allTags
                            .map((tag) => FilterChip(
                          label: Text(tag),
                          selected: _selectedTags.contains(tag),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final filter = PropertyFilter(
                            minPrice: _minPrice == 0 ? null : _minPrice,
                            maxPrice: _maxPrice == 1000000 ? null : _maxPrice,
                            location: _selectedLocation,
                            status: _selectedStatus,
                            tags: _selectedTags,
                          );
                          widget.onApplyFilter(filter);
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppTheme.spacing12,
        top: AppTheme.spacing12,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}