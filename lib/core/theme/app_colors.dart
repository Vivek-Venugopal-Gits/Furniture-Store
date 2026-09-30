import 'package:flutter/material.dart';

/// Curated color palette for the Furniture Store application.
/// Blends rich walnut brown identity with warm cream, soft beige, and pastel accents.
class AppColors {
  AppColors._();

  // Primary Walnut Brown palette
  static const Color primaryWalnut = Color(0xFF3E2723); // Deep Walnut Brown
  static const Color primaryWalnutLight = Color(0xFF4E342E);
  static const Color secondaryWarmBrown = Color(0xFF795548); // Warm Brown
  static const Color tertiaryCognac = Color(0xFF8D6E63);

  // Background & Surface
  static const Color backgroundCream = Color(0xFFFBF9F5); // Warm Cream / Ivory
  static const Color surfaceSoftBeige = Color(0xFFF3EFEA); // Soft Beige
  static const Color surfaceElevated = Color(0xFFFFFFFF); // Crisp Card White
  static const Color surfaceBorder = Color(0xFFE6E0D8);

  // Accents
  static const Color accentMutedSage = Color(0xFF7A9A8B); // Muted Sage
  static const Color accentSageLight = Color(0xFFEAF1EE);
  static const Color accentDustyRose = Color(0xFFC27D68); // Dusty Rose / Terracotta
  static const Color accentRoseLight = Color(0xFFFBF0ED);

  // Text & Content
  static const Color textDarkEspresso = Color(0xFF1F1610); // Dark Espresso
  static const Color textSecondary = Color(0xFF6B635B); // Warm Slate Grey
  static const Color textMuted = Color(0xFF9E968E); // Light Warm Muted
  static const Color textOnPrimary = Color(0xFFFFFDF9);

  // Status & Utility
  static const Color starGold = Color(0xFFE5A93C);
  static const Color success = Color(0xFF4A7C59);
  static const Color error = Color(0xFFC0392B);
  static const Color discountBadge = Color(0xFFC27D68); // Terracotta discount badge
}
