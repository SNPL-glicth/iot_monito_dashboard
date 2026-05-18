import '../../../../core/network/api_client.dart';

class AdminUser {
  AdminUser({
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

class AdminUsersRepository {
  AdminUsersRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<AdminUser>> fetchUsers() async {
    final list = await _apiClient.getList('/admin/users');
    return list.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminUser> createUser({
    required String username,
    required String email,
    required String password,
    required String role,
    bool isActive = true,
  }) async {
    final json = await _apiClient.postJsonAndDecode('/admin/users', {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'isActive': isActive,
    });
    return AdminUser.fromJson(json);
  }

  Future<AdminUser> updateUser({
    required String id,
    String? username,
    String? email,
    String? password,
    String? role,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (role != null) body['role'] = role;
    if (isActive != null) body['isActive'] = isActive;

    final json = await _apiClient.putJsonAndDecode('/admin/users/$id', body);
    return AdminUser.fromJson(json);
  }

  Future<void> deleteUser(String id) async {
    await _apiClient.delete('/admin/users/$id');
  }
}
