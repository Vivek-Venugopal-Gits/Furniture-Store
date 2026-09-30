import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../products/bloc/product_bloc.dart';
import '../../products/bloc/product_event.dart';
import '../../products/bloc/product_state.dart';
import '../widgets/product_card.dart';

/// Explore page allowing curated browsing across dynamic furniture collections.
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Curated Collections'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is! ProductLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryWalnut),
            );
          }

          final categories = state.categories;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: categories.length,
            separatorBuilder: (_, index) => const SizedBox(height: 28),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final matchingProducts = state.allProducts
                  .where((p) => p.category.toLowerCase() == cat.toLowerCase())
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primaryWalnut,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Select this category in the main catalog
                          context
                              .read<ProductBloc>()
                              .add(CategorySelected(cat));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Filtered to $cat in Home catalog'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Text(
                              'View all',
                              style: TextStyle(
                                color: AppColors.secondaryWarmBrown,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 11,
                              color: AppColors.secondaryWarmBrown,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 270,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: matchingProducts.length,
                      separatorBuilder: (_, sIndex) => const SizedBox(width: 14),
                      itemBuilder: (context, pIndex) {
                        return SizedBox(
                          width: 180,
                          child: ProductCard(
                            product: matchingProducts[pIndex],
                            heroTagPrefix: 'explore_${cat}_$pIndex',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
