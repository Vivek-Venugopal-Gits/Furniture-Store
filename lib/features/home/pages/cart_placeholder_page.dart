import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Decorative cart placeholder page highlighting intentional showroom design.
class CartPlaceholderPage extends StatelessWidget {
  final VoidCallback? onExploreTapped;

  const CartPlaceholderPage({super.key, this.onExploreTapped});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Shopping Bag'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoftBeige,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 48,
                  color: AppColors.secondaryWarmBrown,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Showroom Bag',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryWalnut,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              const Text(
                'In this portfolio demonstration, checkout and purchase workflows are intentionally excluded to focus on Discovery, Filtering, and Performance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onExploreTapped,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Continue Discovering'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
