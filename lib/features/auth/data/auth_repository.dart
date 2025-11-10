import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/app_user.dart';
import 'user_repository.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    ref.read(userRepositoryProvider),
  );
});

// Provider for auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authState();
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepository(this._firebaseAuth, this._userRepository);

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth state changes
  Stream<User?> authState() {
    return _firebaseAuth.authStateChanges();
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get and store ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken != null) {
        await _secureStorage.write(key: 'idToken', value: idToken);
        // Debug: Print token (only for development)
        print('DEBUG - ID Token: $idToken');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('User creation failed');
      }

      // Update display name
      await user.updateDisplayName(name);

      // Create AppUser object
      final appUser = AppUser.fromFirebaseUser(user, displayName: name);

      // Create user document and default wallet in Firestore
      await _userRepository.createUserWithDefaultWallet(appUser);

      // Get and store ID token
      final idToken = await user.getIdToken();
      if (idToken != null) {
        await _secureStorage.write(key: 'idToken', value: idToken);
        print('DEBUG - ID Token: $idToken');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _secureStorage.delete(key: 'idToken');
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return await user.getIdToken(forceRefresh);
      }
      return null;
    } catch (e) {
      print('Failed to get ID token: $e');
      return null;
    }
  }

  // Get stored ID token from secure storage
  Future<String?> getStoredIdToken() async {
    try {
      return await _secureStorage.read(key: 'idToken');
    } catch (e) {
      print('Failed to read stored token: $e');
      return null;
    }
  }

  // Refresh and update stored ID token
  Future<void> refreshIdToken() async {
    try {
      final token = await getIdToken(forceRefresh: true);
      if (token != null) {
        await _secureStorage.write(key: 'idToken', value: token);
      }
    } catch (e) {
      print('Failed to refresh token: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
