/// Modelos auxiliares para CrmDashboardContent
class SectionSnapshot<T> {
  const SectionSnapshot({
    this.data,
    this.loading = false,
    this.error,
  });

  final T? data;
  final bool loading;
  final String? error;

  SectionSnapshot<T> copyWith({
    T? data,
    bool? loading,
    String? error,
  }) {
    return SectionSnapshot<T>(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
