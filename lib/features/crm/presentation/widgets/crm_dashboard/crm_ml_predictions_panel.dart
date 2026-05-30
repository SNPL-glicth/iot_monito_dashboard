import 'package:flutter/material.dart';

import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';
import '../../../../alerts/data/models/unified_alert_item.dart';
import '../../../../monitoring/data/models/prediction_view_model.dart';
import '../../../../devices/presentation/pages/sensor_details_route_page.dart';
import '../crm_dashboard_helpers.dart';

/// Panel de predicciones ML y advertencias del dashboard CRM.
class CrmMlPredictionsPanel extends StatelessWidget {
  const CrmMlPredictionsPanel({
    super.key,
    required this.warnings,
    required this.predictions,
  });

  final List<UnifiedAlertItem> warnings;
  final List<PredictionViewModel> predictions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWarningsCard(context),
        SizedBox(height: DesignSpacing.md),
        _buildPredictionsCard(),
      ],
    );
  }

  Widget _buildWarningsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border.all(color: DesignColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: DesignColors.amber),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text('Advertencias (ML)', style: DesignTextStyles.cardTitle),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            if (warnings.isEmpty)
              Text('Sin advertencias.', style: DesignTextStyles.bodyText)
            else
              ...warnings.take(5).map((a) {
                final color = CrmDashboardHelpers.severityColor(a.severity);
                final isDeltaSpike =
                    a.source == 'ml' && (a.eventCode ?? '').toUpperCase() == 'DELTA_SPIKE';
                final displayTitle = isDeltaSpike
                    ? '[INMEDIATO] ${a.title} (${a.severity.toUpperCase()})'
                    : '${a.title} (${a.severity.toUpperCase()})';

                final subtitle = <String>[
                  if (isDeltaSpike) 'Detector online' else 'ML · ${a.status}',
                  if (a.sensorName != null && a.sensorName!.isNotEmpty) a.sensorName!,
                  CrmDashboardHelpers.formatDateTime(a.occurredAt),
                ].join(' · ');

                return Padding(
                  padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                  child: InkWell(
                    onTap: () {
                      final sid = a.sensorId;
                      if (sid == null || sid.isEmpty) return;
                      Navigator.of(context).pushNamed(
                        '/sensor/$sid',
                        arguments: SensorDetailsArgs(sensorId: sid),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: DesignSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayTitle,
                                style: DesignTextStyles.bodyText,
                              ),
                              SizedBox(height: 2),
                              Text(subtitle, style: DesignTextStyles.bodyText),
                              if (a.message != null && a.message!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Text(a.message!, style: DesignTextStyles.bodyText),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border.all(color: DesignColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: DesignColors.cyan),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text('Predicciones', style: DesignTextStyles.cardTitle),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            if (predictions.isEmpty)
              Text('No hay predicciones.', style: DesignTextStyles.bodyText)
            else
              ...predictions.take(10).map((p) {
                final target = CrmDashboardHelpers.formatDateTime(p.targetTimestamp);
                final predictedAt = CrmDashboardHelpers.formatDateTime(p.predictedAt);

                final subtitle = <String>[
                  p.deviceName,
                  'objetivo: $target',
                  'gen: $predictedAt',
                  'conf: ${p.confidence}',
                ].join(' · ');

                return Padding(
                  padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.chevron_right, color: DesignColors.textSecondary),
                      SizedBox(width: DesignSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p.sensorName} → ${p.predictedValue} ${p.unit}',
                              style: DesignTextStyles.bodyText,
                            ),
                            SizedBox(height: 2),
                            Text(subtitle, style: DesignTextStyles.bodyText),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
