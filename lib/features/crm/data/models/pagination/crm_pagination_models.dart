/// Modelos de paginación CRM
library;

class CrmPagedResponse<T> {
  CrmPagedResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });

  final int page;
  final int pageSize;
  final int total;
  final List<T> items;

  factory CrmPagedResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) itemFromJson,
  }) {
    final rawItems = (json['items'] as List?) ?? const [];
    return CrmPagedResponse(
      page: int.tryParse((json['page'] ?? '1').toString()) ?? 1,
      pageSize: int.tryParse((json['pageSize'] ?? '20').toString()) ?? 20,
      total: int.tryParse((json['total'] ?? '0').toString()) ?? 0,
      items: rawItems
          .whereType<Map>()
          .map((e) => itemFromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}
