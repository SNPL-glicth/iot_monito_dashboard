import 'package:flutter/material.dart';

import '../../../../alerts/data/models/unified_alert_item.dart';
import '../../../../monitoring/data/models/prediction_view_model.dart';
import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
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
        const SizedBox(height: 12),
        _buildPredictionsCard(),
      ],
    );
  }

  Widget _buildWarningsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Advertencias (ML)', style: DashboardTextStyles.deviceTitle),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (warnings.isEmpty)
              const Text('Sin advertencias.', style: DashboardTextStyles.sensorMeta)
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
                  padding: const EdgeInsets.only(bottom: 10),
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
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayTitle,
                                style: DashboardTextStyles.alertTitle,
                              ),
                              const SizedBox(height: 2),
                              Text(subtitle, style: DashboardTextStyles.sensorMeta),
                              if (a.message != null && a.message!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(a.message!, style: DashboardTextStyles.alertText),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.deepPurpleAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Predicciones', style: DashboardTextStyles.deviceTitle),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (predictions.isEmpty)
              const Text('No hay predicciones.', style: DashboardTextStyles.sensorMeta)
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
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.chevron_right, color: Colors.white54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p.sensorName} → ${p.predictedValue} ${p.unit}',
                              style: DashboardTextStyles.sensorTitle,
                            ),
                            const SizedBox(height: 2),
                            Text(subtitle, style: DashboardTextStyles.sensorMeta),
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
