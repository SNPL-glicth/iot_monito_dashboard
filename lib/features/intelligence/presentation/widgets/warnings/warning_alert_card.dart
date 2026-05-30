import 'package:flutter/material.dart';

import '../../../../../features/alerts/data/models/alert_with_state.dart';
import '../../../../../features/devices/presentation/pages/sensor_details_route_page.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Tarjeta de alerta estilo trading moderno.
class WarningAlertCard extends StatelessWidget {
  const WarningAlertCard({
    super.key,
    required this.alert,
  });

  final AlertWithState alert;

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return DesignColors.red;
      case 'warning':
        return DesignColors.amber;
      default:
        return Colors.tealAccent;
    }
  }

  static IconData severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = severityColor(alert.severity);
    final icon = severityIcon(alert.severity);

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          onTap: () {
            final sid = alert.sensorId;
            if (sid == null || sid.isEmpty) return;
            Navigator.of(context).pushNamed(
              '/sensor/$sid',
              arguments: SensorDetailsArgs(sensorId: sid),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(DesignSpacing.sm),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.sensors,
                                size: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  alert.sensorName ?? 'Sensor',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
                      decoration: BoxDecoration(
                        color: alert.isActive
                            ? color.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: alert.isActive
                              ? color.withValues(alpha: 0.4)
                              : Colors.grey.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        alert.isActive ? 'ACTIVA' : 'ATENDIDA',
                        style: TextStyle(
                          color: alert.isActive ? color : Colors.grey,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (alert.message != null && alert.message!.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    child: Text(
                      alert.message!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.device_hub,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    SizedBox(width: 4),
                    Text(
                      alert.deviceName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    SizedBox(width: 4),
                    Text(
                      alert.occurredAt,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
