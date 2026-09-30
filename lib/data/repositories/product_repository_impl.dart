import '../datasources/product_local_data_source.dart';
import '../models/product.dart';
import '../../domain/repositories/product_repository.dart';

/// Implementation of ProductRepository handling local data retrieval, dynamic category extraction,
/// and discovery filtering/sorting pipelines.
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource _localDataSource;

  ProductRepositoryImpl({required ProductLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<Product>> getProducts() async {
    return _localDataSource.loadProducts();
  }

  @override
  List<String> extractCategories(List<Product> products) {
    final Set<String> categories = {};
    for (final product in products) {
      final cat = product.category.trim();
      if (cat.isNotEmpty) {
        categories.add(cat);
      }
    }
    return categories.toList();
  }

  @override
  List<String> extractSubcategories(List<Product> products, String? category) {
    final Set<String> subcategories = {};
    final filtered = (category == null || category.isEmpty || category == 'All')
        ? products
        : products.where(
            (p) => p.category.toLowerCase() == category.toLowerCase(),
          );

    for (final product in filtered) {
      final sub = product.subcategory.trim();
      if (sub.isNotEmpty) {
        subcategories.add(sub);
      }
    }
    return subcategories.toList();
  }

  @override
  ({double min, double max}) computePriceRange(List<Product> products) {
    if (products.isEmpty) {
      return (min: 0.0, max: 100000.0);
    }
    double min = products.first.price.toDouble();
    double max = products.first.price.toDouble();

    for (final p in products) {
      final price = p.price.toDouble();
      if (price < min) min = price;
      if (price > max) max = price;
    }
    return (min: min, max: max);
  }

  @override
  List<Product> filterAndSortProducts({
    required List<Product> allProducts,
    String? searchQuery,
    String? category,
    String? subcategory,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    ProductSortOption sortOption = ProductSortOption.newest,
  }) {
    // 1. Map each item with its original JSON dataset index for stable "Newest" sorting
    final indexedProducts = allProducts.asMap().entries.toList();

    // 2. Filter pipeline
    final filtered = indexedProducts.where((entry) {
      final product = entry.value;

      // Search filter on Product.name
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        if (!product.name.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (category != null && category.isNotEmpty && category != 'All') {
        if (product.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
      }

      // Subcategory filter
      if (subcategory != null && subcategory.isNotEmpty && subcategory != 'All') {
        if (product.subcategory.toLowerCase() != subcategory.toLowerCase()) {
          return false;
        }
      }

      // Price range filter
      final price = product.price.toDouble();
      if (minPrice != null && price < minPrice) {
        return false;
      }
      if (maxPrice != null && price > maxPrice) {
        return false;
      }

      // Rating filter
      if (minRating != null && minRating > 0) {
        if (product.rating < minRating) {
          return false;
        }
      }

      return true;
    }).toList();

    // 3. Sorting pipeline (separated cleanly from filtering)
    filtered.sort((a, b) {
      switch (sortOption) {
        case ProductSortOption.priceLowToHigh:
          return a.value.price.compareTo(b.value.price);
        case ProductSortOption.priceHighToLow:
          return b.value.price.compareTo(a.value.price);
        case ProductSortOption.rating:
          return b.value.rating.compareTo(a.value.rating);
        case ProductSortOption.newest:
          // Preserve dataset index order as newest-to-oldest
          return a.key.compareTo(b.key);
      }
    });

    return filtered.map((entry) => entry.value).toList();
  }
}
