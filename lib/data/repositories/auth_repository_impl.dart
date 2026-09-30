import '../datasources/user_local_data_source.dart';
import '../models/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository managing local user persistence and session state.
class AuthRepositoryImpl implements AuthRepository {
  final UserLocalDataSource _localDataSource;

  AuthRepositoryImpl({required UserLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<User?> checkAuthSession() async {
    final activeEmail = await _localDataSource.getActiveSessionEmail();
    if (activeEmail == null || activeEmail.isEmpty) {
      return null;
    }
    return _localDataSource.findUserByEmail(activeEmail);
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final user = await _localDataSource.authenticateUser(email, password);
    if (user == null) {
      throw Exception('Invalid email or password.');
    }
    await _localDataSource.setActiveSessionEmail(user.email);
    return user;
  }

  @override
  Future<void> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final existingUser = await _localDataSource.findUserByEmail(email);
    if (existingUser != null) {
      throw Exception('An account with this email already exists.');
    }

    final newUser = User(
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      password: password,
    );

    await _localDataSource.saveUser(newUser);
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearActiveSession();
  }

  @override
  Future<User?> getCurrentUser() async {
    return checkAuthSession();
  }
}
