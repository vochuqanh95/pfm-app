import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/home/home_page.dart';

// Provider for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,

    // Redirect logic based on auth state
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final isAuthenticated = user != null;

      // Define auth and non-auth routes
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      // If user is authenticated and trying to access auth pages, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // If user is not authenticated and trying to access protected pages, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // No redirect needed
      return null;
    },

    // Listen to auth state changes for automatic redirects
    refreshListenable: _AuthStateNotifier(authRepository),

    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ForgotPasswordPage(),
        ),
      ),

      // Protected Routes
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomePage(),
        ),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Custom notifier to trigger router refreshes on auth state changes
class _AuthStateNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;

  _AuthStateNotifier(this._authRepository) {
    // Listen to auth state changes
    _authRepository.authState().listen((_) {
      notifyListeners();
    });
  }
}
