import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furniture_store/app.dart';
import 'package:furniture_store/data/models/product.dart';
import 'package:furniture_store/data/models/user.dart';
import 'package:furniture_store/domain/repositories/auth_repository.dart';
import 'package:furniture_store/domain/repositories/product_repository.dart';

class FakeAuthRepository implements AuthRepository {
  User? currentUser;

  @override
  Future<User?> checkAuthSession() async => currentUser;

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<User> login({required String email, required String password}) async {
    final user = User(
      fullName: 'Test User',
      email: email,
      phone: '9876543210',
      password: password,
    );
    currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }

  @override
  Future<void> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    currentUser = User(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );
  }
}

class FakeProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts() async => [];

  @override
  List<String> extractCategories(List<Product> products) => [];

  @override
  List<String> extractSubcategories(List<Product> products, String? category) => [];

  @override
  ({double min, double max}) computePriceRange(List<Product> products) =>
      (min: 0.0, max: 100000.0);

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
  }) =>
      [];
}

void main() {
  testWidgets('FurnitureStoreApp renders and navigates to LoginPage when unauthenticated',
      (WidgetTester tester) async {
    final fakeAuth = FakeAuthRepository();
    final fakeProduct = FakeProductRepository();

    await tester.pumpWidget(
      FurnitureStoreApp(
        authRepository: fakeAuth,
        productRepository: fakeProduct,
      ),
    );

    // Initial check triggers AuthLoading / splash
    await tester.pump();
    // Allow asynchronous checkAuthSession to resolve
    await tester.pumpAndSettle();

    // Verify LoginPage appears
    expect(find.text('Furniture Store'), findsWidgets);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
