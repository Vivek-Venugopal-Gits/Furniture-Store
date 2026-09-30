import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/pages/login_page.dart';
import 'features/navigation/main_screen.dart';
import 'features/products/bloc/product_bloc.dart';
import 'features/products/bloc/product_event.dart';

/// Root application widget configuring MultiRepositoryProvider, MultiBlocProvider,
/// AppTheme, and reactive authentication gatekeeping.
class FurnitureStoreApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProductRepository productRepository;

  const FurnitureStoreApp({
    super.key,
    required this.authRepository,
    required this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ProductRepository>.value(value: productRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository: authRepository)
              ..add(const CheckAuthStatus()),
          ),
          BlocProvider<ProductBloc>(
            create: (_) => ProductBloc(productRepository: productRepository)
              ..add(const LoadProducts()),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AuthGatekeeper(),
        ),
      ),
    );
  }
}

/// Gatekeeper inspecting AuthBloc session state to route either to MainScreen or LoginPage.
class AuthGatekeeper extends StatelessWidget {
  const AuthGatekeeper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        // Only trigger top-level route swaps between Authenticated and Unauthenticated/Initial
        if (current is AuthLoading && previous is Authenticated) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        if (state is Authenticated) {
          return const MainScreen();
        }

        if (state is Unauthenticated ||
            state is AuthFailure ||
            state is RegistrationSuccess) {
          return const LoginPage();
        }

        // Elegant Splash Loader while checking local session
        return Scaffold(
          backgroundColor: AppColors.backgroundCream,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryWalnut.withValues(alpha: 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    AppConstants.appLogoPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primaryWalnut,
                      child: const Icon(
                        Icons.chair_outlined,
                        size: 120,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryWarmBrown,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 36),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryWalnut,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
