import 'admin_user.dart';

/// DTO de respuesta paginada para listados de usuarios administrativos.
class PagedUsersResponse {
  const PagedUsersResponse({required this.items, required this.hasMore});

  final List<AdminUser> items;
  final bool hasMore;
}
