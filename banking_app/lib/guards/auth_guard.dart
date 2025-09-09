import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/services/auth_service.dart';
import 'package:banking_app/screens/login_screen.dart';

/// Widget that protects routes requiring authentication
class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool requireAuth;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAuth = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // If auth service is not initialized yet, show loading
        if (!authService.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If route requires auth but user is not logged in, show login
        if (requireAuth && !authService.isLoggedIn) {
          return const LoginScreen();
        }

        // If route doesn't require auth but user is logged in, this handles
        // the case where logged-in users try to access login page
        if (!requireAuth && authService.isLoggedIn) {
          // Redirect to dashboard if already logged in and trying to access login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show the requested page
        return child;
      },
    );
  }
}

/// Helper widget for routes that require authentication
class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      requireAuth: true,
      child: child,
    );
  }
}

/// Helper widget for public routes (like login)
class PublicRoute extends StatelessWidget {
  final Widget child;

  const PublicRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      requireAuth: false,
      child: child,
    );
  }
}
