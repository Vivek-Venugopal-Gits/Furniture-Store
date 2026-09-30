import 'package:equatable/equatable.dart';
import '../../../data/models/product.dart';
import '../../../domain/repositories/product_repository.dart';

/// States emitted by ProductBloc.
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Emitted during initial JSON asset loading and parsing.
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Emitted when products have loaded, managing discovery filters, sorting, and infinite scroll pagination.
class ProductLoaded extends ProductState {
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final List<Product> visibleProducts;
  final int visibleCount;
  final bool hasMore;
  final bool isLoadingMore;

  // Dynamic Discovery Context
  final List<String> categories;
  final List<String> subcategories;

  // Active Discovery Filters
  final String searchQuery;
  final String selectedCategory; // 'All' or specific category
  final String selectedSubcategory; // 'All' or specific subcategory
  final double datasetMinPrice;
  final double datasetMaxPrice;
  final double selectedMinPrice;
  final double selectedMaxPrice;
  final double selectedMinRating;
  final ProductSortOption sortOption;

  const ProductLoaded({
    required this.allProducts,
    required this.filteredProducts,
    required this.visibleProducts,
    required this.visibleCount,
    required this.hasMore,
    required this.isLoadingMore,
    required this.categories,
    required this.subcategories,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.selectedSubcategory = 'All',
    required this.datasetMinPrice,
    required this.datasetMaxPrice,
    required this.selectedMinPrice,
    required this.selectedMaxPrice,
    this.selectedMinRating = 0.0,
    this.sortOption = ProductSortOption.newest,
  });

  ProductLoaded copyWith({
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    List<Product>? visibleProducts,
    int? visibleCount,
    bool? hasMore,
    bool? isLoadingMore,
    List<String>? categories,
    List<String>? subcategories,
    String? searchQuery,
    String? selectedCategory,
    String? selectedSubcategory,
    double? datasetMinPrice,
    double? datasetMaxPrice,
    double? selectedMinPrice,
    double? selectedMaxPrice,
    double? selectedMinRating,
    ProductSortOption? sortOption,
  }) {
    return ProductLoaded(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      visibleCount: visibleCount ?? this.visibleCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubcategory: selectedSubcategory ?? this.selectedSubcategory,
      datasetMinPrice: datasetMinPrice ?? this.datasetMinPrice,
      datasetMaxPrice: datasetMaxPrice ?? this.datasetMaxPrice,
      selectedMinPrice: selectedMinPrice ?? this.selectedMinPrice,
      selectedMaxPrice: selectedMaxPrice ?? this.selectedMaxPrice,
      selectedMinRating: selectedMinRating ?? this.selectedMinRating,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  /// Helper to know if any non-default filter is currently active
  bool get hasActiveFilters =>
      (selectedCategory != 'All') ||
      (selectedSubcategory != 'All') ||
      (selectedMinPrice > datasetMinPrice) ||
      (selectedMaxPrice < datasetMaxPrice) ||
      (selectedMinRating > 0.0) ||
      (sortOption != ProductSortOption.newest);

  @override
  List<Object?> get props => [
        allProducts,
        filteredProducts,
        visibleProducts,
        visibleCount,
        hasMore,
        isLoadingMore,
        categories,
        subcategories,
        searchQuery,
        selectedCategory,
        selectedSubcategory,
        datasetMinPrice,
        datasetMaxPrice,
        selectedMinPrice,
        selectedMaxPrice,
        selectedMinRating,
        sortOption,
      ];
}

/// Emitted if reading the product JSON dataset fails.
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
