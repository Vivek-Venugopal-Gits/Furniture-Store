import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:furniture_store/core/utils/validators.dart';
import 'package:furniture_store/data/models/dimensions.dart';
import 'package:furniture_store/data/models/product.dart';
import 'package:furniture_store/data/models/user.dart';
import 'package:furniture_store/domain/repositories/product_repository.dart';
import 'package:furniture_store/data/repositories/product_repository_impl.dart';
import 'package:furniture_store/data/datasources/product_local_data_source.dart';

class MockProductLocalDataSource implements ProductLocalDataSource {
  final List<Product> products;
  MockProductLocalDataSource(this.products);

  @override
  Future<List<Product>> loadProducts() async => products;
}

void main() {
  group('Validators Tests', () {
    test('validateFullName succeeds on valid names', () {
      expect(Validators.validateFullName('Aditi Sharma'), isNull);
      expect(Validators.validateFullName('John Doe'), isNull);
    });

    test('validateFullName fails on empty or short names', () {
      expect(Validators.validateFullName(''), isNotNull);
      expect(Validators.validateFullName('   '), isNotNull);
      expect(Validators.validateFullName('A'), isNotNull);
    });

    test('validateEmail succeeds on valid email format', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('test.dev@sub.domain.co'), isNull);
    });

    test('validateEmail fails on invalid email format', () {
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('@example.com'), isNotNull);
    });

    test('validatePhone succeeds on valid 10-digit Indian numbers', () {
      expect(Validators.validatePhone('9876543210'), isNull);
      expect(Validators.validatePhone('+91 9876543210'), isNull);
      expect(Validators.validatePhone('8123456789'), isNull);
    });

    test('validatePhone fails on invalid numbers', () {
      expect(Validators.validatePhone('12345'), isNotNull);
      expect(Validators.validatePhone('1234567890'), isNotNull); // Doesn't start with 6-9
      expect(Validators.validatePhone('abcd987654'), isNotNull);
    });

    test('validatePassword requires at least 6 characters', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('secretPass'), isNull);
      expect(Validators.validatePassword('12345'), isNotNull);
    });

    test('validateConfirmPassword enforces match', () {
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), isNull);
      expect(Validators.validateConfirmPassword('pass123', 'other'), isNotNull);
    });
  });

  group('Product and Dimensions Model Tests', () {
    test('Dimensions serialization and deserialization', () {
      const dim = Dimensions(width: '48 cm', depth: '53 cm', height: '88 cm');
      final jsonMap = dim.toJson();
      expect(jsonMap['width'], '48 cm');
      expect(jsonMap['depth'], '53 cm');
      expect(jsonMap['height'], '88 cm');

      final deserialized = Dimensions.fromJson(jsonMap);
      expect(deserialized, equals(dim));
    });

    test('Product strictly adheres to required schema', () {
      final sampleJson = {
        "id": 1,
        "name": "Malabar Cane Inset Dining Chair",
        "category": "Chair",
        "subcategory": "Dining Chair",
        "price": 5499,
        "originalPrice": 7499,
        "discountPercentage": 27,
        "description": "Crafted to elevate any dining area.",
        "material": "Solid Rubberwood and Natural Cane",
        "color": "Honey Oak and Muted Beige",
        "dimensions": {
          "width": "48 cm",
          "depth": "53 cm",
          "height": "88 cm"
        },
        "suitableFor": "Dining Room",
        "features": ["Hand-stretched natural octagonal cane backrest"],
        "rating": 4.4,
        "reviewCount": 89,
        "stock": 38,
        "imageUrl": "assets/images/products/chair_01.jpg"
      };

      final product = Product.fromJson(sampleJson);
      expect(product.id, 1);
      expect(product.name, "Malabar Cane Inset Dining Chair");
      expect(product.category, "Chair");
      expect(product.subcategory, "Dining Chair");
      expect(product.price, 5499);
      expect(product.dimensions.width, "48 cm");
      expect(product.features.length, 1);
      expect(product.rating, 4.4);

      final encoded = json.encode(product.toJson());
      expect(encoded, contains('"id":1'));
      expect(encoded, contains('"category":"Chair"'));
    });

    test('User serialization and deserialization', () {
      const user = User(
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '9876543210',
        password: 'password123',
      );
      final jsonMap = user.toJson();
      final fromJson = User.fromJson(jsonMap);
      expect(fromJson, equals(user));
    });
  });

  group('ProductRepositoryImpl Discovery & Filter Tests', () {
    final testProducts = [
      const Product(
        id: 1,
        name: "Malabar Cane Chair",
        category: "Chair",
        subcategory: "Dining Chair",
        price: 5000,
        originalPrice: 7000,
        discountPercentage: 28,
        description: "Test",
        material: "Wood",
        color: "Oak",
        dimensions: Dimensions(width: "40", depth: "40", height: "80"),
        suitableFor: "Dining",
        features: ["Cane"],
        rating: 4.5,
        reviewCount: 50,
        stock: 10,
        imageUrl: "chair_01.jpg",
      ),
      const Product(
        id: 2,
        name: "Nordic Velvet Sofa",
        category: "Sofa",
        subcategory: "3-Seater Sofa",
        price: 35000,
        originalPrice: 45000,
        discountPercentage: 22,
        description: "Test",
        material: "Velvet",
        color: "Blue",
        dimensions: Dimensions(width: "200", depth: "90", height: "85"),
        suitableFor: "Living Room",
        features: ["Plush"],
        rating: 4.8,
        reviewCount: 120,
        stock: 5,
        imageUrl: "sofa_01.jpg",
      ),
      const Product(
        id: 3,
        name: "Sheesham Study Chair",
        category: "Chair",
        subcategory: "Study Chair",
        price: 3000,
        originalPrice: 4000,
        discountPercentage: 25,
        description: "Test",
        material: "Wood",
        color: "Teak",
        dimensions: Dimensions(width: "45", depth: "45", height: "90"),
        suitableFor: "Study",
        features: ["Solid"],
        rating: 4.2,
        reviewCount: 30,
        stock: 15,
        imageUrl: "chair_02.jpg",
      ),
    ];

    late ProductRepositoryImpl repo;

    setUp(() {
      repo = ProductRepositoryImpl(
        localDataSource: MockProductLocalDataSource(testProducts),
      );
    });

    test('extractCategories dynamically derives categories from product data', () {
      final categories = repo.extractCategories(testProducts);
      expect(categories, containsAll(['Chair', 'Sofa']));
      expect(categories.length, 2);
    });

    test('extractSubcategories dynamically derives subcategories', () {
      final chairSubs = repo.extractSubcategories(testProducts, 'Chair');
      expect(chairSubs, containsAll(['Dining Chair', 'Study Chair']));
      expect(chairSubs.length, 2);

      final sofaSubs = repo.extractSubcategories(testProducts, 'Sofa');
      expect(sofaSubs, equals(['3-Seater Sofa']));
    });

    test('computePriceRange computes bounds', () {
      final range = repo.computePriceRange(testProducts);
      expect(range.min, 3000.0);
      expect(range.max, 35000.0);
    });

    test('filter by search query operates on Product.name case-insensitively', () {
      final res = repo.filterAndSortProducts(
        allProducts: testProducts,
        searchQuery: 'cane',
      );
      expect(res.length, 1);
      expect(res.first.name, "Malabar Cane Chair");
    });

    test('filter by category operates correctly', () {
      final res = repo.filterAndSortProducts(
        allProducts: testProducts,
        category: 'Chair',
      );
      expect(res.length, 2);
    });

    test('filter by subcategory operates correctly', () {
      final res = repo.filterAndSortProducts(
        allProducts: testProducts,
        subcategory: 'Study Chair',
      );
      expect(res.length, 1);
      expect(res.first.name, "Sheesham Study Chair");
    });

    test('sorting by price low to high', () {
      final res = repo.filterAndSortProducts(
        allProducts: testProducts,
        sortOption: ProductSortOption.priceLowToHigh,
      );
      expect(res.map((p) => p.price).toList(), [3000, 5000, 35000]);
    });

    test('sorting by price high to low', () {
      final res = repo.filterAndSortProducts(
        allProducts: testProducts,
        sortOption: ProductSortOption.priceHighToLow,
      );
      expect(res.map((p) => p.price).toList(), [35000, 5000, 3000]);
    });

    test('sorting by rating', () {
      final res = repo.filterAndSortProducts(
        allProducts: testProducts,
        sortOption: ProductSortOption.rating,
      );
      expect(res.first.rating, 4.8);
      expect(res.last.rating, 4.2);
    });

    test('sorting by newest preserves dataset order', () {
      final res = repo.filterAndSortProducts(
        allProducts: testProducts,
        sortOption: ProductSortOption.newest,
      );
      expect(res[0].id, 1);
      expect(res[1].id, 2);
      expect(res[2].id, 3);
    });
  });
}
