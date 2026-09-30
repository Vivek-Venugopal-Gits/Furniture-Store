import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../products/bloc/product_bloc.dart';
import '../../products/bloc/product_event.dart';
import '../../products/bloc/product_state.dart';

/// Modal bottom sheet allowing dynamic category, subcategory, price range,
/// rating filter selection, and sorting options.
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: const FilterBottomSheet(),
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedCategory;
  late String _selectedSubcategory;
  late RangeValues _priceRange;
  late double _minRating;
  late ProductSortOption _sortOption;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProductBloc>().state;
    if (state is ProductLoaded) {
      _selectedCategory = state.selectedCategory;
      _selectedSubcategory = state.selectedSubcategory;
      _priceRange = RangeValues(
        state.selectedMinPrice.clamp(state.datasetMinPrice, state.datasetMaxPrice),
        state.selectedMaxPrice.clamp(state.datasetMinPrice, state.datasetMaxPrice),
      );
      _minRating = state.selectedMinRating;
      _sortOption = state.sortOption;
    } else {
      _selectedCategory = 'All';
      _selectedSubcategory = 'All';
      _priceRange = const RangeValues(0, 100000);
      _minRating = 0.0;
      _sortOption = ProductSortOption.newest;
    }
  }

  String _formatPrice(double val) {
    return '₹${val.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductLoaded) return const SizedBox.shrink();

        final categories = ['All', ...state.categories];

        // Dynamically compute subcategories for current category selection
        final availableSubcategories = ['All'];
        final filteredForSubs = (_selectedCategory == 'All')
            ? state.allProducts
            : state.allProducts.where(
                (p) => p.category.toLowerCase() == _selectedCategory.toLowerCase(),
              );
        final uniqueSubs = filteredForSubs
            .map((p) => p.subcategory.trim())
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
        availableSubcategories.addAll(uniqueSubs);

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primaryWalnut,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),

                  // 1. Dynamic Category Filter
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected =
                          cat.toLowerCase() == _selectedCategory.toLowerCase();
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                              _selectedSubcategory = 'All'; // Reset subcategory
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 2. Dynamic Subcategory Filter
                  Text(
                    'Subcategory',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSubcategories.map((sub) {
                      final isSelected = sub.toLowerCase() ==
                          _selectedSubcategory.toLowerCase();
                      return ChoiceChip(
                        label: Text(sub),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSubcategory = sub;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 3. Dynamic Price Range Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price Range',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${_formatPrice(_priceRange.start)} - ${_formatPrice(_priceRange.end)}',
                        style: const TextStyle(
                          color: AppColors.primaryWalnut,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: state.datasetMinPrice,
                    max: state.datasetMaxPrice,
                    divisions: 30,
                    activeColor: AppColors.primaryWalnut,
                    inactiveColor: AppColors.surfaceSoftBeige,
                    labels: RangeLabels(
                      _formatPrice(_priceRange.start),
                      _formatPrice(_priceRange.end),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. Rating Filter
                  Text(
                    'Minimum Rating',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildRatingChip('All', 0.0),
                      const SizedBox(width: 8),
                      _buildRatingChip('★ 3.5+', 3.5),
                      const SizedBox(width: 8),
                      _buildRatingChip('★ 4.0+', 4.0),
                      const SizedBox(width: 8),
                      _buildRatingChip('★ 4.5+', 4.5),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. Sort By Option
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildSortRadio(
                    title: 'Newest Arrivals',
                    value: ProductSortOption.newest,
                  ),
                  _buildSortRadio(
                    title: 'Price: Low to High',
                    value: ProductSortOption.priceLowToHigh,
                  ),
                  _buildSortRadio(
                    title: 'Price: High to Low',
                    value: ProductSortOption.priceHighToLow,
                  ),
                  _buildSortRadio(
                    title: 'Customer Rating',
                    value: ProductSortOption.rating,
                  ),
                  const SizedBox(height: 28),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      // Clear All Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context
                                .read<ProductBloc>()
                                .add(const ClearAllFilters());
                            Navigator.of(context).pop();
                          },
                          child: const Text('Clear All'),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Apply Filters Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<ProductBloc>().add(
                                  FilterCriteriaApplied(
                                    category: _selectedCategory,
                                    subcategory: _selectedSubcategory,
                                    minPrice: _priceRange.start,
                                    maxPrice: _priceRange.end,
                                    minRating: _minRating,
                                    sortOption: _sortOption,
                                  ),
                                );
                            Navigator.of(context).pop();
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingChip(String label, double rating) {
    final isSelected = _minRating == rating;
    return Expanded(
      child: ChoiceChip(
        label: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textDarkEspresso,
            ),
          ),
        ),
        selected: isSelected,
        showCheckmark: false,
        selectedColor: AppColors.primaryWalnut,
        backgroundColor: AppColors.surfaceSoftBeige,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _minRating = rating;
            });
          }
        },
      ),
    );
  }

  Widget _buildSortRadio({
    required String title,
    required ProductSortOption value,
  }) {
    final isSelected = _sortOption == value;
    return InkWell(
      onTap: () {
        setState(() {
          _sortOption = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryWalnut : AppColors.surfaceBorder,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primaryWalnut : AppColors.textDarkEspresso,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
