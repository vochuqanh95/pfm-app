import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_user.dart';

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _walletsCollection => _firestore.collection('wallets');

  // Create user document in Firestore
  Future<void> createUserDoc(AppUser user) async {
    try {
      await _usersCollection.doc(user.userId).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Get user by ID
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Watch user changes (stream)
  Stream<AppUser?> watchUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppUser.fromMap(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
      }
      return null;
    });
  }

  // Update user document
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = Timestamp.now();
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Create default wallet for new user
  Future<void> createDefaultWallet(String uid, String currency) async {
    try {
      final now = Timestamp.now();
      final walletData = {
        'user_id': uid,
        'group_id': null,
        'name': 'Cash',
        'type': 'cash',
        'currency': currency,
        'opening_balance': 0,
        'balance': 0,
        'archived': false,
        'created_at': now,
        'updated_at': now,
      };

      await _walletsCollection.add(walletData);
    } catch (e) {
      throw Exception('Failed to create default wallet: $e');
    }
  }

  // Create user with default wallet in a batch operation
  Future<void> createUserWithDefaultWallet(AppUser user) async {
    try {
      final batch = _firestore.batch();

      // Create user document
      batch.set(_usersCollection.doc(user.userId), user.toMap());

      // Create default wallet
      final walletRef = _walletsCollection.doc();
      final now = Timestamp.now();
      batch.set(walletRef, {
        'user_id': user.userId,
        'group_id': null,
        'name': 'Cash',
        'type': 'cash',
        'currency': user.currency,
        'opening_balance': 0,
        'balance': 0,
        'archived': false,
        'created_at': now,
        'updated_at': now,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create user with default wallet: $e');
    }
  }
}
