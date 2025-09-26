class AppUser {
  final int id;
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
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
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
