import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../products/bloc/product_bloc.dart';
import '../../products/bloc/product_event.dart';
import '../../products/bloc/product_state.dart';

/// Horizontal dynamic category selector.
/// Strictly extracts categories from loaded product state without hardcoded lists.
class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductLoaded) {
          return const SizedBox.shrink();
        }

        // Dynamically extracted categories from the dataset + 'All' option
        final categories = ['All', ...state.categories];
        final selectedCategory = state.selectedCategory;

        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.toLowerCase() == selectedCategory.toLowerCase();

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<ProductBloc>().add(CategorySelected(category));
                    }
                  },
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textDarkEspresso,
                  ),
                  backgroundColor: AppColors.surfaceElevated,
                  selectedColor: AppColors.primaryWalnut,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryWalnut
                        : AppColors.surfaceBorder,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
