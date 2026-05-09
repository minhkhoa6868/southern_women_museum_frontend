class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool isAdmin;
  final String language;
  final bool isNotificationEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.isAdmin,
    required this.language,
    required this.isNotificationEnabled,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isAdmin: json['is_admin'] ?? json['isAdmin'] ?? false,
      language: json['language'] ?? 'en',
      isNotificationEnabled: json['is_notification_enabled'] ?? json['isNotificationEnabled'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'isAdmin': isAdmin,
      'language': language,
      'isNotificationEnabled': isNotificationEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class AuthResponse {
  final String accessToken;
  final User? user;

  AuthResponse({
    required this.accessToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}
