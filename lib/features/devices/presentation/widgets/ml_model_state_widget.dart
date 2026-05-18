import 'package:flutter/material.dart';

import '../../data/models/ml_features_model.dart';
import 'ml_model_state/ml_model_compact.dart';
import 'ml_model_state/ml_model_full.dart';
import 'ml_model_state/ml_model_no_data.dart';

/// ML Model State Widget - Shows ML confidence and pattern as a visual gauge.
/// 
/// FASE 2.5: This widget makes ML observable by showing:
/// - Confidence gauge (0-100%)
/// - Pattern detected
/// - Trend direction
/// - Stability score
/// - Anomaly indicator
/// 
/// Users can see at a glance how confident the ML is and what it's detecting.
class MLModelStateWidget extends StatelessWidget {
  const MLModelStateWidget({
    super.key,
    required this.features,
    this.compact = false,
    this.showDetails = true,
  });

  final MLFeaturesModel? features;
  final bool compact;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    if (features == null) {
      return const MlModelNoData();
    }

    if (compact) {
      return MlModelCompact(features: features!);
    }

    return MlModelFull(features: features!, showDetails: showDetails);
  }
}

