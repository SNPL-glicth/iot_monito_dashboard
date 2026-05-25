import '../../../../core/network/api_client.dart';
import 'models/admin_user.dart';
import 'models/paged_users_response.dart';

class AdminUsersRepository {
  AdminUsersRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PagedUsersResponse> fetchUsers({int page = 1, int pageSize = 20, String? q}) async {
    String url = '/admin/users?page=$page&pageSize=$pageSize';
    if (q != null && q.isNotEmpty) url += '&q=$q';
    final list = await _apiClient.getList(url);
    final items = list.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();
    return PagedUsersResponse(items: items, hasMore: items.length >= pageSize);
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
