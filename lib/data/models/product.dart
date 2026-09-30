import 'package:equatable/equatable.dart';
import 'dimensions.dart';

/// Strongly-typed Product model matching the exact JSON structure provided in the prompt.
/// No additional fields are introduced.
class Product extends Equatable {
  final int id;
  final String name;
  final String category;
  final String subcategory;
  final num price;
  final num originalPrice;
  final num discountPercentage;
  final String description;
  final String material;
  final String color;
  final Dimensions dimensions;
  final String suitableFor;
  final List<String> features;
  final double rating;
  final int reviewCount;
  final int stock;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.price,
    required this.originalPrice,
    required this.discountPercentage,
    required this.description,
    required this.material,
    required this.color,
    required this.dimensions,
    required this.suitableFor,
    required this.features,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String? ?? '',
      price: json['price'] as num? ?? 0,
      originalPrice: json['originalPrice'] as num? ?? 0,
      discountPercentage: json['discountPercentage'] as num? ?? 0,
      description: json['description'] as String? ?? '',
      material: json['material'] as String? ?? '',
      color: json['color'] as String? ?? '',
      dimensions: Dimensions.fromJson(
        json['dimensions'] as Map<String, dynamic>? ?? {},
      ),
      suitableFor: json['suitableFor'] as String? ?? '',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      stock: json['stock'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'description': description,
      'material': material,
      'color': color,
      'dimensions': dimensions.toJson(),
      'suitableFor': suitableFor,
      'features': features,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        subcategory,
        price,
        originalPrice,
        discountPercentage,
        description,
        material,
        color,
        dimensions,
        suitableFor,
        features,
        rating,
        reviewCount,
        stock,
        imageUrl,
      ];
}
