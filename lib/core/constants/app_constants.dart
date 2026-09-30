/// Centralized constants used across the Furniture Store application.
class AppConstants {
  AppConstants._();

  static const String appName = 'Furniture Store';
  static const String appTagline = 'Discover furniture for your space';

  // Asset paths
  static const String productsJsonPath = 'assets/data/products.json';
  static const String usersJsonPath = 'assets/data/users.json';
  static const String heroBannerPath = 'assets/images/products/hero_banner.jpg';
  static const String appLogoPath = 'assets/images/app_logo.png';

  // Local storage keys
  static const String prefsUsersKey = 'persisted_users_json';
  static const String prefsActiveUserEmailKey = 'active_user_session_email';

  // Pagination
  static const int initialBatchSize = 8;
  static const int loadMoreBatchSize = 8;
}
