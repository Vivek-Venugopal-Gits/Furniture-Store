import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../models/product.dart';

/// Contract and implementation for loading products from the local assets JSON.
abstract class ProductLocalDataSource {
  Future<List<Product>> loadProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final AssetBundle _assetBundle;

  ProductLocalDataSourceImpl({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  @override
  Future<List<Product>> loadProducts() async {
    try {
      final jsonString = await _assetBundle.loadString(AppConstants.productsJsonPath);
      final List<dynamic> decodedList = json.decode(jsonString) as List<dynamic>;

      return decodedList
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load local product dataset: $e');
    }
  }
}
