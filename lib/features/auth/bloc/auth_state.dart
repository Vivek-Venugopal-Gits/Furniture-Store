import 'package:equatable/equatable.dart';
import '../../../data/models/user.dart';

/// States emitted by AuthBloc.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Emitted while performing asynchronous auth operations.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Emitted when a valid user session is verified or after successful login.
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Emitted when no user is logged in (displays Login/Signup UI).
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Emitted when user registration completes successfully, guiding to Login.
class RegistrationSuccess extends AuthState {
  final String message;

  const RegistrationSuccess({
    this.message = 'Registration successful! Please log in.',
  });

  @override
  List<Object?> get props => [message];
}

/// Emitted on login or signup errors (e.g. invalid credentials, duplicate email).
class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
