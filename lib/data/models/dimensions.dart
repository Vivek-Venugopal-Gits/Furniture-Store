import 'package:equatable/equatable.dart';

/// Strongly-typed dimensions model for furniture products.
class Dimensions extends Equatable {
  final String width;
  final String depth;
  final String height;

  const Dimensions({
    required this.width,
    required this.depth,
    required this.height,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: json['width'] as String? ?? '',
      depth: json['depth'] as String? ?? '',
      height: json['height'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'depth': depth,
      'height': height,
    };
  }

  @override
  List<Object?> get props => [width, depth, height];
}
