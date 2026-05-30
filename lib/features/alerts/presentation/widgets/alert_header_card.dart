import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/alerts/alert_snapshot_service.dart';
import 'alert_detail_widgets.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


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
        ? DesignColors.red
        : (snapshot.isWarning ? DesignColors.amber : Colors.tealAccent);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
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
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.sensorName,
                        style: DesignTextStyles.cardTitle,
                      ),
                      Text(
                        snapshot.deviceName,
                        style: DesignTextStyles.bodyText,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.lg),
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
            SizedBox(height: DesignSpacing.lg),
            const Divider(color: Colors.white12),
            SizedBox(height: DesignSpacing.md),
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
                    DesignColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.md),
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
                      DesignColors.red,
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
                      DesignColors.amber,
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
