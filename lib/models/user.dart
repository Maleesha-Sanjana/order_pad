class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'waiter',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };
}

class AppUser {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String? phone;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phone,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'waiter',
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'name': name,
    'phone': phone,
    'createdAt': createdAt?.toIso8601String(),
  };
}

class AuthRequest {
  final String email;
  final String password;
  final String? name;
  final String? phone;
  final String? role;

  const AuthRequest({
    required this.email,
    required this.password,
    this.name,
    this.phone,
    this.role,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    if (name != null) 'name': name,
    if (phone != null) 'phone': phone,
    if (role != null) 'role': role,
  };
}

class AuthResponse {
  final AppUser user;
  final String token;

  const AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
