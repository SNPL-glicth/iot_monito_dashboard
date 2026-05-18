import '../../data/models/ml_features_model.dart';

/// Data point with ML features for enhanced visualization.
class MLEnhancedDataPoint {
  const MLEnhancedDataPoint({
    required this.timestamp,
    required this.value,
    this.state = 'NORMAL',
    this.events = const [],
    this.mlFeatures,
  });

  final DateTime timestamp;
  final double value;
  final String state;
  final List<String> events;
  final MLFeaturesModel? mlFeatures;

  double get x => timestamp.millisecondsSinceEpoch.toDouble();

  bool get isAlert => state.toUpperCase() == 'ALERT';
  bool get isWarning => state.toUpperCase() == 'WARNING';
  bool get hasDeltaSpike => events.any((e) => e.toUpperCase() == 'DELTA_SPIKE');
  bool get hasMLFeatures => mlFeatures != null;

  /// Get baseline from ML features (or value if not available)
  double get baseline => mlFeatures?.baseline ?? value;

  /// Get confidence from ML features (or 0 if not available)
  double get confidence => mlFeatures?.confidence ?? 0.0;

  /// Get upper confidence band
  double get upperBand => mlFeatures?.upperBand ?? value;

  /// Get lower confidence band
  double get lowerBand => mlFeatures?.lowerBand ?? value;
}
