import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String userId;
  final String name;
  final String email;
  final String currency;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.userId,
    required this.name,
    required this.email,
    this.currency = 'VND',
    this.language = 'vi',
    required this.createdAt,
    required this.updatedAt,
  });

  // Create AppUser from Firebase User (after authentication)
  factory AppUser.fromFirebaseUser(User user, {String? displayName}) {
    final now = DateTime.now();
    return AppUser(
      userId: user.uid,
      name: displayName ?? user.displayName ?? 'User',
      email: user.email ?? '',
      currency: 'VND',
      language: 'vi',
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create AppUser from Firestore document
  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
      userId: documentId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      currency: map['currency'] as String? ?? 'VND',
      language: map['language'] as String? ?? 'vi',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert AppUser to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'currency': currency,
      'language': language,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  AppUser copyWith({
    String? userId,
    String? name,
    String? email,
    String? currency,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AppUser(userId: $userId, name: $name, email: $email, currency: $currency, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.currency == currency &&
        other.language == language;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        email.hashCode ^
        currency.hashCode ^
        language.hashCode;
  }
}
