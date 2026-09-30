import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

/// Business logic component for the Furniture Store catalog, dynamic categories,
/// multi-factor filtering, sorting, and infinite scroll pagination.
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<CategorySelected>(_onCategorySelected);
    on<SubcategorySelected>(_onSubcategorySelected);
    on<FilterCriteriaApplied>(_onFilterCriteriaApplied);
    on<ClearAllFilters>(_onClearAllFilters);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final allProducts = await _productRepository.getProducts();
      final categories = _productRepository.extractCategories(allProducts);
      final subcategories = _productRepository.extractSubcategories(allProducts, null);
      final priceRange = _productRepository.computePriceRange(allProducts);

      final filtered = _productRepository.filterAndSortProducts(
        allProducts: allProducts,
        searchQuery: '',
        category: 'All',
        subcategory: 'All',
        minPrice: priceRange.min,
        maxPrice: priceRange.max,
        minRating: 0.0,
        sortOption: ProductSortOption.newest,
      );

      final initialCount = filtered.length < AppConstants.initialBatchSize
          ? filtered.length
          : AppConstants.initialBatchSize;
      final visible = filtered.take(initialCount).toList();

      emit(ProductLoaded(
        allProducts: allProducts,
        filteredProducts: filtered,
        visibleProducts: visible,
        visibleCount: initialCount,
        hasMore: initialCount < filtered.length,
        isLoadingMore: false,
        categories: categories,
        subcategories: subcategories,
        searchQuery: '',
        selectedCategory: 'All',
        selectedSubcategory: 'All',
        datasetMinPrice: priceRange.min,
        datasetMaxPrice: priceRange.max,
        selectedMinPrice: priceRange.min,
        selectedMaxPrice: priceRange.max,
        selectedMinRating: 0.0,
        sortOption: ProductSortOption.newest,
      ));
    } catch (e) {
      emit(ProductError('Failed to load furniture collection: $e'));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<ProductState> emit,
  ) {
    if (state is! ProductLoaded) return;
    final current = state as ProductLoaded;

    final filtered = _productRepository.filterAndSortProducts(
      allProducts: current.allProducts,
      searchQuery: event.query,
      category: current.selectedCategory,
      subcategory: current.selectedSubcategory,
      minPrice: current.selectedMinPrice,
      maxPrice: current.selectedMaxPrice,
      minRating: current.selectedMinRating,
      sortOption: current.sortOption,
    );

    final newCount = filtered.length < AppConstants.initialBatchSize
        ? filtered.length
        : AppConstants.initialBatchSize;

    emit(current.copyWith(
      searchQuery: event.query,
      filteredProducts: filtered,
      visibleProducts: filtered.take(newCount).toList(),
      visibleCount: newCount,
      hasMore: newCount < filtered.length,
      isLoadingMore: false,
    ));
  }

  void _onCategorySelected(
    CategorySelected event,
    Emitter<ProductState> emit,
  ) {
    if (state is! ProductLoaded) return;
    final current = state as ProductLoaded;

    // Dynamically extract subcategories matching this category
    final dynamicSubcategories = _productRepository.extractSubcategories(
      current.allProducts,
      event.category == 'All' ? null : event.category,
    );

    final filtered = _productRepository.filterAndSortProducts(
      allProducts: current.allProducts,
      searchQuery: current.searchQuery,
      category: event.category,
      subcategory: 'All', // Reset subcategory when switching category
      minPrice: current.selectedMinPrice,
      maxPrice: current.selectedMaxPrice,
      minRating: current.selectedMinRating,
      sortOption: current.sortOption,
    );

    final newCount = filtered.length < AppConstants.initialBatchSize
        ? filtered.length
        : AppConstants.initialBatchSize;

    emit(current.copyWith(
      selectedCategory: event.category,
      selectedSubcategory: 'All',
      subcategories: dynamicSubcategories,
      filteredProducts: filtered,
      visibleProducts: filtered.take(newCount).toList(),
      visibleCount: newCount,
      hasMore: newCount < filtered.length,
      isLoadingMore: false,
    ));
  }

  void _onSubcategorySelected(
    SubcategorySelected event,
    Emitter<ProductState> emit,
  ) {
    if (state is! ProductLoaded) return;
    final current = state as ProductLoaded;

    final filtered = _productRepository.filterAndSortProducts(
      allProducts: current.allProducts,
      searchQuery: current.searchQuery,
      category: current.selectedCategory,
      subcategory: event.subcategory,
      minPrice: current.selectedMinPrice,
      maxPrice: current.selectedMaxPrice,
      minRating: current.selectedMinRating,
      sortOption: current.sortOption,
    );

    final newCount = filtered.length < AppConstants.initialBatchSize
        ? filtered.length
        : AppConstants.initialBatchSize;

    emit(current.copyWith(
      selectedSubcategory: event.subcategory,
      filteredProducts: filtered,
      visibleProducts: filtered.take(newCount).toList(),
      visibleCount: newCount,
      hasMore: newCount < filtered.length,
      isLoadingMore: false,
    ));
  }

  void _onFilterCriteriaApplied(
    FilterCriteriaApplied event,
    Emitter<ProductState> emit,
  ) {
    if (state is! ProductLoaded) return;
    final current = state as ProductLoaded;

    final cat = event.category ?? current.selectedCategory;
    final sub = event.subcategory ?? current.selectedSubcategory;
    final minP = event.minPrice ?? current.selectedMinPrice;
    final maxP = event.maxPrice ?? current.selectedMaxPrice;
    final minR = event.minRating ?? current.selectedMinRating;
    final sort = event.sortOption;

    final dynamicSubcategories = _productRepository.extractSubcategories(
      current.allProducts,
      cat == 'All' ? null : cat,
    );

    final filtered = _productRepository.filterAndSortProducts(
      allProducts: current.allProducts,
      searchQuery: current.searchQuery,
      category: cat,
      subcategory: sub,
      minPrice: minP,
      maxPrice: maxP,
      minRating: minR,
      sortOption: sort,
    );

    final newCount = filtered.length < AppConstants.initialBatchSize
        ? filtered.length
        : AppConstants.initialBatchSize;

    emit(current.copyWith(
      selectedCategory: cat,
      selectedSubcategory: sub,
      selectedMinPrice: minP,
      selectedMaxPrice: maxP,
      selectedMinRating: minR,
      sortOption: sort,
      subcategories: dynamicSubcategories,
      filteredProducts: filtered,
      visibleProducts: filtered.take(newCount).toList(),
      visibleCount: newCount,
      hasMore: newCount < filtered.length,
      isLoadingMore: false,
    ));
  }

  void _onClearAllFilters(
    ClearAllFilters event,
    Emitter<ProductState> emit,
  ) {
    if (state is! ProductLoaded) return;
    final current = state as ProductLoaded;

    final allSubcategories = _productRepository.extractSubcategories(
      current.allProducts,
      null,
    );

    final filtered = _productRepository.filterAndSortProducts(
      allProducts: current.allProducts,
      searchQuery: '',
      category: 'All',
      subcategory: 'All',
      minPrice: current.datasetMinPrice,
      maxPrice: current.datasetMaxPrice,
      minRating: 0.0,
      sortOption: ProductSortOption.newest,
    );

    final newCount = filtered.length < AppConstants.initialBatchSize
        ? filtered.length
        : AppConstants.initialBatchSize;

    emit(current.copyWith(
      searchQuery: '',
      selectedCategory: 'All',
      selectedSubcategory: 'All',
      selectedMinPrice: current.datasetMinPrice,
      selectedMaxPrice: current.datasetMaxPrice,
      selectedMinRating: 0.0,
      sortOption: ProductSortOption.newest,
      subcategories: allSubcategories,
      filteredProducts: filtered,
      visibleProducts: filtered.take(newCount).toList(),
      visibleCount: newCount,
      hasMore: newCount < filtered.length,
      isLoadingMore: false,
    ));
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;
    final current = state as ProductLoaded;

    // Guard against redundant requests
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    // Slight micro-delay for smooth rendering and visual loading feedback
    await Future.delayed(const Duration(milliseconds: 350));

    final nextCount = (current.visibleCount + AppConstants.loadMoreBatchSize)
        .clamp(0, current.filteredProducts.length);
    final nextVisible = current.filteredProducts.take(nextCount).toList();

    emit(current.copyWith(
      visibleCount: nextCount,
      visibleProducts: nextVisible,
      hasMore: nextCount < current.filteredProducts.length,
      isLoadingMore: false,
    ));
  }
}
