import 'package:flutter/material.dart';

import 'health_header_widget.dart';
import 'activity_section_widget.dart';
import 'error_metrics_section_widget.dart';
import 'quality_section_widget.dart';
import 'accuracy_section_widget.dart';
import 'anomaly_section_widget.dart';
import 'warnings_recommendations_widget.dart';
import 'pattern_analysis_section_widget.dart';
import 'micro_delta_section_widget.dart';
import 'error_margin_section_widget.dart';
import 'ignored_data_section_widget.dart';
import 'ml_features_section_widget.dart';
import 'footer_widget.dart';

/// Body widget containing all intelligence health sections
class IntelligenceHealthBodyWidget extends StatelessWidget {
  const IntelligenceHealthBodyWidget({
    super.key,
    required this.data,
    required this.mlFeatures,
  });

  final dynamic data;
  final dynamic mlFeatures;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Estado principal con health score
        HealthHeaderWidget(
          healthLabel: data.healthLabel,
          healthScore: data.healthScore,
          modelHealth: data.modelHealth,
        ),
        const SizedBox(height: 16),

        // 1.5. ML Features Widget (NUEVO)
        MLFeaturesSectionWidget(mlFeatures: mlFeatures),
        const SizedBox(height: 16),

        // 2. Actividad del modelo
        ActivitySectionWidget(
          predictionsLast1h: data.modelActivity.predictionsLast1h,
          predictionsLast24h: data.modelActivity.predictionsLast24h,
          predictionsLast7d: data.modelActivity.predictionsLast7d,
          avgPredictionsPerHour: data.modelActivity.avgPredictionsPerHour,
        ),
        const SizedBox(height: 16),

        // 3. Métricas de error
        ErrorMetricsSectionWidget(
          sampleSize: data.errorMetrics.sampleSize,
          mae: data.errorMetrics.mae ?? 0.0,
          rmse: data.errorMetrics.rmse ?? 0.0,
          mape: data.errorMetrics.mape,
          stdDev: data.errorMetrics.stdDev ?? 0.0,
        ),
        const SizedBox(height: 16),

        // 4. Calidad de predicciones
        QualitySectionWidget(
          avgConfidence: data.predictionQuality.avgConfidence,
          lowConfidenceRate: data.predictionQuality.lowConfidenceRate,
          highConfidenceRate: data.predictionQuality.highConfidenceRate,
          confidenceDistribution: data.predictionQuality.confidenceDistribution,
        ),
        const SizedBox(height: 16),

        // 5. Precisión por umbral
        AccuracySectionWidget(
          totalEvaluated: data.accuracyMetrics.totalEvaluated,
          withinThreshold5pct: data.accuracyMetrics.withinThreshold5pct,
          withinThreshold10pct: data.accuracyMetrics.withinThreshold10pct,
          withinThreshold20pct: data.accuracyMetrics.withinThreshold20pct,
        ),
        const SizedBox(height: 16),

        // 6. Detección de anomalías
        AnomalySectionWidget(
          totalAnomalies: data.anomalyDetection.totalAnomalies,
          anomalyRate: data.anomalyDetection.anomalyRate,
        ),
        const SizedBox(height: 16),

        // 7. NUEVO: Patrones detectados
        PatternAnalysisSectionWidget(
          patternsDetected: data.patternAnalysis.patternsDetected,
          dominantPattern: data.patternAnalysis.dominantPattern,
        ),
        const SizedBox(height: 16),

        // 8. NUEVO: Sensibilidad a micro-cambios
        MicroDeltaSectionWidget(
          microChangeRate: data.microDeltaSensitivity.microChangeRate,
          totalChanges: data.microDeltaSensitivity.totalChanges,
          microChanges: data.microDeltaSensitivity.microChanges,
          ignoredChangesCount: data.microDeltaSensitivity.ignoredChangesCount,
          sensitivityThreshold: data.microDeltaSensitivity.sensitivityThreshold,
        ),
        const SizedBox(height: 16),

        // 9. NUEVO: Margen de error
        ErrorMarginSectionWidget(
          estimatedMarginPct: data.errorMarginAnalysis.estimatedMarginPct,
          isReliable: data.errorMarginAnalysis.isReliable,
          marginConfidence: data.errorMarginAnalysis.marginConfidence,
          explanation: data.errorMarginAnalysis.explanation,
        ),
        const SizedBox(height: 16),

        // 10. NUEVO: Datos ignorados
        if (data.ignoredDataReasons.isNotEmpty) ...[
          IgnoredDataSectionWidget(reasons: data.ignoredDataReasons),
          const SizedBox(height: 16),
        ],

        // 11. Advertencias
        if (data.warnings.isNotEmpty) ...[
          WarningsSectionWidget(warnings: data.warnings),
          const SizedBox(height: 16),
        ],

        // 12. Recomendaciones
        if (data.recommendations.isNotEmpty)
          RecommendationsSectionWidget(recommendations: data.recommendations),

        const SizedBox(height: 24),
        
        // Footer con timestamp
        FooterWidget(timestamp: data.timestamp),
        const SizedBox(height: 8),
      ],
    );
  }
}
