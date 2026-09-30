import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/product.dart';

/// Comprehensive, elegant Product Details page presenting every attribute
/// of the product JSON with artisanal furniture luxury styling.
class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final String? heroTag;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.heroTag,
  });

  String _formatPrice(num price) {
    final val = price.toInt().toString();
    if (val.length <= 3) return '₹$val';
    final lastThree = val.substring(val.length - 3);
    final rest = val.substring(0, val.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (m) => '${m[1]},',
    );
    return '₹$formattedRest,$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discountPercentage > 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Immersive Sliver AppBar with Product Image & Hero
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: AppColors.surfaceElevated,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.primaryWalnut,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: AppColors.primaryWalnut,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: heroTag ?? 'catalog_product_image_${product.id}',
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceSoftBeige,
                    child: const Icon(
                      Icons.chair_outlined,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Product Specifications & Details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Subcategory Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoftBeige,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.secondaryWarmBrown,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentSageLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          product.subcategory,
                          style: const TextStyle(
                            color: AppColors.accentMutedSage,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Product Title
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryWalnut,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Rating & Reviews Pill
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.starGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.starGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDarkEspresso,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '(${product.reviewCount} customer reviews)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pricing Block with Discount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryWalnut,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                          _formatPrice(product.originalPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentDustyRose,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${product.discountPercentage.toInt()}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),

                  // Full Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryWalnut,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // Dimensions (Width, Depth, Height 3-box visual layout)
                  Text(
                    'Dimensions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryWalnut,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDimensionBox('Width', product.dimensions.width),
                      const SizedBox(width: 12),
                      _buildDimensionBox('Depth', product.dimensions.depth),
                      const SizedBox(width: 12),
                      _buildDimensionBox('Height', product.dimensions.height),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Material, Color, and Suitable For
                  Text(
                    'Specifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryWalnut,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildSpecTile(
                    icon: Icons.architecture,
                    label: 'Material',
                    value: product.material,
                  ),
                  _buildSpecTile(
                    icon: Icons.palette_outlined,
                    label: 'Color Finish',
                    value: product.color,
                  ),
                  _buildSpecTile(
                    icon: Icons.room_outlined,
                    label: 'Suitable For',
                    value: product.suitableFor,
                  ),
                  const SizedBox(height: 28),

                  // Key Features Array
                  Text(
                    'Craftsmanship & Features',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryWalnut,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...product.features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            margin: const EdgeInsets.only(top: 2),
                            decoration: const BoxDecoration(
                              color: AppColors.accentSageLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.accentMutedSage,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textDarkEspresso,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stock Availability Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: product.stock < 10
                          ? AppColors.accentRoseLight
                          : AppColors.surfaceSoftBeige,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: product.stock < 10
                            ? AppColors.accentDustyRose.withValues(alpha: 0.3)
                            : AppColors.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          product.stock < 10
                              ? Icons.alarm_outlined
                              : Icons.inventory_2_outlined,
                          color: product.stock < 10
                              ? AppColors.accentDustyRose
                              : AppColors.primaryWalnut,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${product.stock} items remaining in stock',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: product.stock < 10
                                ? AppColors.accentDustyRose
                                : AppColors.primaryWalnut,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryWalnut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.secondaryWarmBrown),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 2,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkEspresso,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
