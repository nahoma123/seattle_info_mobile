import 'package:flutter/foundation.dart'; // For @required and kDebugMode

// Helper for robust date parsing
DateTime? _parseDate(String? dateString) {
  if (dateString == null) return null;
  try {
    return DateTime.tryParse(dateString);
  } catch (e) {
    if (kDebugMode) {
      print('Error parsing date: $dateString, Error: $e');
    }
    return null;
  }
}

class AppUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final String authProvider;
  final bool isEmailVerified;
  final String role;
  final bool isFirstPostApproved;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  AppUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    required this.authProvider,
    required this.isEmailVerified,
    required this.role,
    required this.isFirstPostApproved,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      authProvider: json['auth_provider'] as String? ?? 'firebase', // Default if missing
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      role: json['role'] as String? ?? 'user', // Default if missing
      isFirstPostApproved: json['is_first_post_approved'] as bool? ?? false,
      createdAt: _parseDate(json['created_at'] as String?),
      updatedAt: _parseDate(json['updated_at'] as String?),
      lastLoginAt: _parseDate(json['last_login_at'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture_url': profilePictureUrl,
      'auth_provider': authProvider,
      'is_email_verified': isEmailVerified,
      'role': role,
      'is_first_post_approved': isFirstPostApproved,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
    String? authProvider,
    bool? isEmailVerified,
    String? role,
    bool? isFirstPostApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      authProvider: authProvider ?? this.authProvider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      isFirstPostApproved: isFirstPostApproved ?? this.isFirstPostApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is AppUser &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        email == other.email &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        profilePictureUrl == other.profilePictureUrl &&
        authProvider == other.authProvider &&
        isEmailVerified == other.isEmailVerified &&
        role == other.role &&
        isFirstPostApproved == other.isFirstPostApproved &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        lastLoginAt == other.lastLoginAt;

  @override
  int get hashCode =>
    id.hashCode ^
    email.hashCode ^
    firstName.hashCode ^
    lastName.hashCode ^
    profilePictureUrl.hashCode ^
    authProvider.hashCode ^
    isEmailVerified.hashCode ^
    role.hashCode ^
    isFirstPostApproved.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    lastLoginAt.hashCode;

 @override
 String toString() {
   return 'AppUser{id: $id, email: $email, firstName: $firstName, lastName: $lastName, role: $role, isFirstPostApproved: $isFirstPostApproved}';
 }
}
