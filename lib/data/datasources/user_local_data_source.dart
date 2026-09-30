import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user.dart';

/// Contract for managing local user dataset and active user session.
abstract class UserLocalDataSource {
  Future<List<User>> getAllUsers();
  Future<void> saveUser(User user);
  Future<User?> findUserByEmail(String email);
  Future<User?> authenticateUser(String email, String password);
  Future<void> setActiveSessionEmail(String email);
  Future<String?> getActiveSessionEmail();
  Future<void> clearActiveSession();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences _preferences;
  final AssetBundle _assetBundle;

  UserLocalDataSourceImpl({
    required SharedPreferences preferences,
    AssetBundle? assetBundle,
  })  : _preferences = preferences,
        _assetBundle = assetBundle ?? rootBundle;

  @override
  Future<List<User>> getAllUsers() async {
    final persistedJson = _preferences.getString(AppConstants.prefsUsersKey);

    if (persistedJson != null && persistedJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(persistedJson) as List<dynamic>;
        return decoded
            .map((item) => User.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Fallback to initial assets if stored data was corrupted
      }
    }

    // Read bundled initial user dataset (fallback)
    try {
      final initialAssetString =
          await _assetBundle.loadString(AppConstants.usersJsonPath);
      final List<dynamic> decoded =
          json.decode(initialAssetString) as List<dynamic>;
      return decoded
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveUser(User user) async {
    final currentUsers = await getAllUsers();

    // Check duplicate email
    final exists = currentUsers.any(
      (u) => u.email.trim().toLowerCase() == user.email.trim().toLowerCase(),
    );
    if (exists) {
      throw Exception('An account with this email already exists.');
    }

    currentUsers.add(user);

    // Serialize and write to device local storage
    final jsonList = currentUsers.map((u) => u.toJson()).toList();
    final serialized = json.encode(jsonList);
    await _preferences.setString(AppConstants.prefsUsersKey, serialized);
  }

  @override
  Future<User?> findUserByEmail(String email) async {
    final users = await getAllUsers();
    final normalized = email.trim().toLowerCase();
    try {
      return users.firstWhere(
        (u) => u.email.trim().toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User?> authenticateUser(String email, String password) async {
    final users = await getAllUsers();
    final normalized = email.trim().toLowerCase();
    try {
      return users.firstWhere(
        (u) =>
            u.email.trim().toLowerCase() == normalized &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setActiveSessionEmail(String email) async {
    await _preferences.setString(AppConstants.prefsActiveUserEmailKey, email);
  }

  @override
  Future<String?> getActiveSessionEmail() async {
    return _preferences.getString(AppConstants.prefsActiveUserEmailKey);
  }

  @override
  Future<void> clearActiveSession() async {
    await _preferences.remove(AppConstants.prefsActiveUserEmailKey);
  }
}
