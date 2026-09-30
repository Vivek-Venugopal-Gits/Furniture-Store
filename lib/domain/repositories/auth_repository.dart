import '../../data/models/user.dart';

/// Abstract contract for authentication and user session management.
abstract class AuthRepository {
  /// Checks if a valid user session exists on device launch.
  Future<User?> checkAuthSession();

  /// Authenticates user against locally persisted accounts.
  Future<User> login({
    required String email,
    required String password,
  });

  /// Registers a new user and persists in local storage.
  Future<void> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  /// Clears active session.
  Future<void> logout();

  /// Gets the currently authenticated user if one exists.
  Future<User?> getCurrentUser();
}
