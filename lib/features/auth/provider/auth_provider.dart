import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/user_repository.dart';
import '../domain/app_user.dart';

// Current user provider (from Firebase Auth)
final currentFirebaseUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authState();
});

// Current AppUser provider (from Firestore)
final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  final firebaseUser = ref.watch(currentFirebaseUserProvider).value;

  if (firebaseUser == null) {
    return Stream.value(null);
  }

  return ref.watch(userRepositoryProvider).watchUser(firebaseUser.uid);
});

// Auth state notifier for handling auth operations
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.data(null));

  // Sign in
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signInWithEmailPassword(email, password);
    });
  }

  // Sign up
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );
    });
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.sendPasswordResetEmail(email);
    });
  }

  // Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
    });
  }

  // Get ID token
  Future<String?> getIdToken() async {
    return await _authRepository.getIdToken();
  }
}

// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// Convenience providers for checking auth state
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(currentFirebaseUserProvider);
  return authState.value != null;
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(currentFirebaseUserProvider);
  return authState.value?.uid;
});
