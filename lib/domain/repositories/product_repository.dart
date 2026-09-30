import '../../data/models/product.dart';

/// Available sorting options for product discovery.
enum ProductSortOption {
  newest,
  priceLowToHigh,
  priceHighToLow,
  rating,
}

/// Abstract contract for product catalog discovery and data operations.
abstract class ProductRepository {
  /// Fetches all products from the local data source.
  Future<List<Product>> getProducts();

  /// Dynamically extracts unique categories from the product list.
  List<String> extractCategories(List<Product> products);

  /// Dynamically extracts subcategories for a given category (or all if category is null/empty).
  List<String> extractSubcategories(List<Product> products, String? category);

  /// Computes the minimum and maximum price across the loaded product collection.
  ({double min, double max}) computePriceRange(List<Product> products);

  /// Applies discovery pipeline: Search -> Category -> Subcategory -> Price Range -> Rating -> Sorting.
  List<Product> filterAndSortProducts({
    required List<Product> allProducts,
    String? searchQuery,
    String? category,
    String? subcategory,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    ProductSortOption sortOption = ProductSortOption.newest,
  });
}
