import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../products/bloc/product_bloc.dart';
import '../../products/bloc/product_event.dart';
import '../../products/bloc/product_state.dart';
import '../widgets/category_selector.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/hero_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';

/// The central marketplace Home Page showcasing dynamic categories,
/// visual editorial banners, responsive product grid, and infinite scrolling.
class HomePage extends StatefulWidget {
  final VoidCallback? onCartTapped;

  const HomePage({super.key, this.onCartTapped});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger loading next batch when user is within 200px of bottom
    if (currentScroll >= (maxScroll - 200)) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<ProductBloc>().add(const LoadMoreProducts());
      }
    }
  }

  void _openFilters() {
    FilterBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryWalnut,
          onRefresh: () async {
            context.read<ProductBloc>().add(const LoadProducts());
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Top Spacing & Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeHeader(onCartTapped: widget.onCartTapped),
                      const SizedBox(height: 18),
                      SearchBarWidget(onFilterTap: _openFilters),
                      const SizedBox(height: 20),
                      const CategorySelector(),
                      const SizedBox(height: 20),
                      const HeroBanner(),
                      const SizedBox(height: 24),

                      // Section Title & Filter Button
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          int totalCount = 0;
                          if (state is ProductLoaded) {
                            totalCount = state.filteredProducts.length;
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Popular Furniture',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: AppColors.primaryWalnut,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (totalCount > 0)
                                    Text(
                                      'Showing $totalCount handcrafted pieces',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: _openFilters,
                                icon: const Icon(
                                  Icons.tune,
                                  size: 16,
                                  color: AppColors.primaryWalnut,
                                ),
                                label: const Text(
                                  'Filter',
                                  style: TextStyle(
                                    color: AppColors.primaryWalnut,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // Product Listing Content (Loading / Error / Empty / Grid)
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading || state is ProductInitial) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryWalnut,
                        ),
                      ),
                    );
                  }

                  if (state is ProductError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textDarkEspresso,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<ProductBloc>()
                                      .add(const LoadProducts());
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is ProductLoaded) {
                    if (state.filteredProducts.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 40,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSoftBeige,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(
                                    Icons.search_off_rounded,
                                    size: 40,
                                    color: AppColors.secondaryWarmBrown,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'No furniture found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryWalnut,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try adjusting your search keywords, category, or filter criteria.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton(
                                  onPressed: () {
                                    context
                                        .read<ProductBloc>()
                                        .add(const ClearAllFilters());
                                  },
                                  child: const Text('Reset All Filters'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final visible = state.visibleProducts;

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ProductCard(product: visible[index]);
                          },
                          childCount: visible.length,
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Infinite Scroll Footer (Loading More / End of List)
              SliverToBoxAdapter(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is! ProductLoaded ||
                        state.filteredProducts.isEmpty) {
                      return const SizedBox(height: 30);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: state.isLoadingMore
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryWalnut,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Loading more furniture...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : (state.hasMore
                                ? const SizedBox.shrink()
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 1,
                                        color: AppColors.surfaceBorder,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "You've viewed all matching pieces",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 24,
                                        height: 1,
                                        color: AppColors.surfaceBorder,
                                      ),
                                    ],
                                  )),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
