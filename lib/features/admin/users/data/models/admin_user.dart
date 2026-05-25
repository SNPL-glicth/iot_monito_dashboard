/// Modelo de dominio para un usuario del sistema administrativo.
class AdminUser {
  const AdminUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
  });

  final String id;
  final String username;
  final String email;
  final String role; // 'admin' | 'operator' | 'viewer'
  final bool isActive;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'].toString(),
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'viewer',
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }
}
