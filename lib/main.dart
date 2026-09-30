import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/datasources/product_local_data_source.dart';
import 'data/datasources/user_local_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistent device storage
  final preferences = await SharedPreferences.getInstance();

  // Instantiate data sources
  final productLocalDataSource = ProductLocalDataSourceImpl();
  final userLocalDataSource = UserLocalDataSourceImpl(preferences: preferences);

  // Instantiate repository implementations
  final productRepository = ProductRepositoryImpl(
    localDataSource: productLocalDataSource,
  );
  final authRepository = AuthRepositoryImpl(
    localDataSource: userLocalDataSource,
  );

  runApp(
    FurnitureStoreApp(
      authRepository: authRepository,
      productRepository: productRepository,
    ),
  );
}
