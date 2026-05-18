/// Punto crudo en tiempo real sin bucketización
class RealtimePointViewModel {
  RealtimePointViewModel({
    required this.timestamp,
    required this.value,
    required this.state,
  });

  final String timestamp;
  final double value;
  final String state; // NORMAL, WARNING, ALERT

  factory RealtimePointViewModel.fromJson(Map<String, dynamic> json) {
    return RealtimePointViewModel(
      timestamp: json['timestamp']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      state: json['state']?.toString() ?? 'NORMAL',
    );
  }
}
