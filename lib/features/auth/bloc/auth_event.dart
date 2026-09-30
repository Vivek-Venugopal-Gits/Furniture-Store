import 'package:equatable/equatable.dart';

/// Events dispatched to AuthBloc.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on app start to check if a saved session exists.
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Dispatched when the user submits credentials on the Login page.
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Dispatched when the user submits registration form on the Signup page.
class SignupSubmitted extends AuthEvent {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  const SignupSubmitted({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, phone, password];
}

/// Dispatched when the user clicks Logout on the Profile page.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Dispatched to reset one-time transient states (like RegistrationSuccess).
class ResetAuthStatus extends AuthEvent {
  const ResetAuthStatus();
}
