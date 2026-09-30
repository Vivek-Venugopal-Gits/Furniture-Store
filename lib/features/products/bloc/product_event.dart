import 'package:equatable/equatable.dart';
import '../../../domain/repositories/product_repository.dart';

/// Events dispatched to ProductBloc.
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on page initialization to load the product dataset from the local JSON.
class LoadProducts extends ProductEvent {
  const LoadProducts();
}

/// Dispatched when the user types in the search bar.
class SearchQueryChanged extends ProductEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Dispatched when user taps a category pill.
class CategorySelected extends ProductEvent {
  final String category;

  const CategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

/// Dispatched when user taps a subcategory pill.
class SubcategorySelected extends ProductEvent {
  final String subcategory;

  const SubcategorySelected(this.subcategory);

  @override
  List<Object?> get props => [subcategory];
}

/// Dispatched from the Filter Bottom Sheet with combined filter criteria.
class FilterCriteriaApplied extends ProductEvent {
  final String? category;
  final String? subcategory;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final ProductSortOption sortOption;

  const FilterCriteriaApplied({
    this.category,
    this.subcategory,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.sortOption = ProductSortOption.newest,
  });

  @override
  List<Object?> get props => [
        category,
        subcategory,
        minPrice,
        maxPrice,
        minRating,
        sortOption,
      ];
}

/// Dispatched to reset all filter and sort parameters back to default state.
class ClearAllFilters extends ProductEvent {
  const ClearAllFilters();
}

/// Dispatched when user scrolls near the bottom of the list to load the next batch.
class LoadMoreProducts extends ProductEvent {
  const LoadMoreProducts();
}
