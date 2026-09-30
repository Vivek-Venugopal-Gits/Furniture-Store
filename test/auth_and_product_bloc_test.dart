import 'package:flutter_test/flutter_test.dart';
import 'package:furniture_store/core/constants/app_constants.dart';
import 'package:furniture_store/data/datasources/user_local_data_source.dart';
import 'package:furniture_store/data/datasources/product_local_data_source.dart';
import 'package:furniture_store/data/models/dimensions.dart';
import 'package:furniture_store/data/models/product.dart';
import 'package:furniture_store/data/repositories/auth_repository_impl.dart';
import 'package:furniture_store/data/repositories/product_repository_impl.dart';
import 'package:furniture_store/features/auth/bloc/auth_bloc.dart';
import 'package:furniture_store/features/auth/bloc/auth_event.dart';
import 'package:furniture_store/features/auth/bloc/auth_state.dart';
import 'package:furniture_store/features/products/bloc/product_bloc.dart';
import 'package:furniture_store/features/products/bloc/product_event.dart';
import 'package:furniture_store/features/products/bloc/product_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProductDataSource implements ProductLocalDataSource {
  final List<Product> list;
  MockProductDataSource(this.list);

  @override
  Future<List<Product>> loadProducts() async => list;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthRepository and Local User Persistence', () {
    late SharedPreferences prefs;
    late UserLocalDataSource userLocalDataSource;
    late AuthRepositoryImpl authRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      userLocalDataSource = UserLocalDataSourceImpl(preferences: prefs);
      authRepo = AuthRepositoryImpl(localDataSource: userLocalDataSource);
    });

    test('Initial user list is empty and session is null', () async {
      final session = await authRepo.checkAuthSession();
      expect(session, isNull);
    });

    test('Signup saves user, and duplicate email is rejected', () async {
      await authRepo.signup(
        fullName: 'Rahul Varma',
        email: 'rahul@example.com',
        phone: '9876543210',
        password: 'password123',
      );

      // Verify duplicate signup fails
      expect(
        () => authRepo.signup(
          fullName: 'Another Person',
          email: 'rahul@example.com',
          phone: '9812345678',
          password: 'password999',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Login fails with invalid credentials', () async {
      await authRepo.signup(
        fullName: 'Rahul Varma',
        email: 'rahul@example.com',
        phone: '9876543210',
        password: 'password123',
      );

      expect(
        () => authRepo.login(
          email: 'rahul@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<Exception>()),
      );

      expect(
        () => authRepo.login(
          email: 'nonexistent@example.com',
          password: 'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Login succeeds, sets session, and logout clears session', () async {
      await authRepo.signup(
        fullName: 'Rahul Varma',
        email: 'rahul@example.com',
        phone: '9876543210',
        password: 'password123',
      );

      final loggedInUser = await authRepo.login(
        email: 'rahul@example.com',
        password: 'password123',
      );

      expect(loggedInUser.email, 'rahul@example.com');

      // Check session
      final session = await authRepo.checkAuthSession();
      expect(session, isNotNull);
      expect(session?.fullName, 'Rahul Varma');

      // Logout
      await authRepo.logout();
      final postLogoutSession = await authRepo.checkAuthSession();
      expect(postLogoutSession, isNull);
    });
  });

  group('AuthBloc Lifecycle Tests', () {
    late SharedPreferences prefs;
    late UserLocalDataSource userLocalDataSource;
    late AuthRepositoryImpl authRepo;
    late AuthBloc authBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      userLocalDataSource = UserLocalDataSourceImpl(preferences: prefs);
      authRepo = AuthRepositoryImpl(localDataSource: userLocalDataSource);
      authBloc = AuthBloc(authRepository: authRepo);
    });

    tearDown(() {
      authBloc.close();
    });

    test('CheckAuthStatus emits Unauthenticated when empty', () async {
      expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          const Unauthenticated(),
        ]),
      );
      authBloc.add(const CheckAuthStatus());
    });

    test('SignupSubmitted emits RegistrationSuccess', () async {
      expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          const RegistrationSuccess(),
        ]),
      );
      authBloc.add(
        const SignupSubmitted(
          fullName: 'Sneha Patel',
          email: 'sneha@example.com',
          phone: '9988776655',
          password: 'password123',
        ),
      );
    });
  });

  group('ProductBloc Infinite Scrolling and Discovery Tests', () {
    // Generate 20 test products across 2 categories
    final List<Product> mock20Products = List.generate(
      20,
      (i) => Product(
        id: i + 1,
        name: i.isEven ? 'Ergonomic Chair #$i' : 'Modern Sofa #$i',
        category: i.isEven ? 'Chair' : 'Sofa',
        subcategory: i.isEven ? 'Office Chair' : 'Fabric Sofa',
        price: 1000 + (i * 500),
        originalPrice: 1500 + (i * 500),
        discountPercentage: 20,
        description: 'Description for product $i',
        material: 'Wood and Fabric',
        color: 'Oak',
        dimensions: const Dimensions(width: '50', depth: '50', height: '90'),
        suitableFor: 'Living Room',
        features: const ['Durable joinery'],
        rating: 4.0 + (i % 5) * 0.2,
        reviewCount: 10 + i,
        stock: 15,
        imageUrl: 'assets/images/products/chair_01.jpg',
      ),
    );

    late ProductRepositoryImpl productRepo;
    late ProductBloc productBloc;

    setUp(() {
      productRepo = ProductRepositoryImpl(
        localDataSource: MockProductDataSource(mock20Products),
      );
      productBloc = ProductBloc(productRepository: productRepo);
    });

    tearDown(() {
      productBloc.close();
    });

    test('LoadProducts loads catalog with initial batch of 8 products', () async {
      productBloc.add(const LoadProducts());

      await expectLater(
        productBloc.stream,
        emitsThrough(
          predicate<ProductState>((state) {
            if (state is! ProductLoaded) return false;
            return state.allProducts.length == 20 &&
                state.visibleProducts.length == AppConstants.initialBatchSize &&
                state.hasMore == true &&
                state.categories.length == 2;
          }),
        ),
      );
    });

    test('LoadMoreProducts appends next batch of 8 products', () async {
      productBloc.add(const LoadProducts());

      // Wait until loaded
      await productBloc.stream.firstWhere((s) => s is ProductLoaded);

      productBloc.add(const LoadMoreProducts());

      await expectLater(
        productBloc.stream,
        emitsThrough(
          predicate<ProductState>((state) {
            if (state is! ProductLoaded) return false;
            return state.visibleProducts.length == 16 && state.hasMore == true;
          }),
        ),
      );
    });

    test('Category filter updates filtered list and resets visible count', () async {
      productBloc.add(const LoadProducts());
      await productBloc.stream.firstWhere((s) => s is ProductLoaded);

      productBloc.add(const CategorySelected('Chair'));

      await expectLater(
        productBloc.stream,
        emitsThrough(
          predicate<ProductState>((state) {
            if (state is! ProductLoaded) return false;
            // 10 chairs total, initial batch is 8
            return state.selectedCategory == 'Chair' &&
                state.filteredProducts.length == 10 &&
                state.visibleProducts.length == 8 &&
                state.hasMore == true;
          }),
        ),
      );
    });
  });
}
