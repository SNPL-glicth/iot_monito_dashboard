import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/alerts/alert_snapshot_service.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import 'alert_detail_widgets.dart';

/// Tarjeta de información del header de una alerta
class AlertHeaderCard extends StatelessWidget {
  const AlertHeaderCard({
    super.key,
    required this.snapshot,
  });

  final AlertSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final severityColor = snapshot.isCritical
        ? Colors.redAccent
        : (snapshot.isWarning ? Colors.orangeAccent : Colors.tealAccent);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  snapshot.isCritical ? Icons.error : Icons.warning,
                  color: severityColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.sensorName,
                        style: DashboardTextStyles.deviceTitle,
                      ),
                      Text(
                        snapshot.deviceName,
                        style: DashboardTextStyles.sensorMeta,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: severityColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    snapshot.severity.toUpperCase(),
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AlertDetailWidgets.infoItem(
                    'Valor detectado',
                    '${snapshot.triggeredValue.toStringAsFixed(2)} ${snapshot.unit}',
                    severityColor,
                  ),
                ),
                Expanded(
                  child: AlertDetailWidgets.infoItem(
                    'Fecha/Hora',
                    DateFormat('dd/MM/yyyy HH:mm:ss').format(snapshot.triggeredAt),
                    Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (snapshot.thresholdMin != null || snapshot.thresholdMax != null)
                  Expanded(
                    child: AlertDetailWidgets.infoItem(
                      'Umbral alerta',
                      AlertDetailWidgets.formatThreshold(
                        snapshot.thresholdMin,
                        snapshot.thresholdMax,
                        snapshot.unit,
                      ),
                      Colors.redAccent,
                    ),
                  ),
                if (snapshot.warningMin != null || snapshot.warningMax != null)
                  Expanded(
                    child: AlertDetailWidgets.infoItem(
                      'Umbral warning',
                      AlertDetailWidgets.formatThreshold(
                        snapshot.warningMin,
                        snapshot.warningMax,
                        snapshot.unit,
                      ),
                      Colors.orangeAccent,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
