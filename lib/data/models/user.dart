import 'package:equatable/equatable.dart';

/// User model representing a registered user in local JSON persistence.
class User extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  const User({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [fullName, email, phone, password];
}
