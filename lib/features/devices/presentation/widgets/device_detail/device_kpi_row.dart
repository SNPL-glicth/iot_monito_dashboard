import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import '../device_detail_helpers.dart';

/// Fila de KPIs del dispositivo: sensores, alertas, advertencias.
class DeviceKpiRow extends StatelessWidget {
  const DeviceKpiRow({
    super.key,
    required this.sensorCount,
    required this.alerts,
    required this.warnings,
    this.pending,
  });

  final int sensorCount;
  final int alerts;
  final int warnings;
  final int? pending;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: DeviceDetailHelpers.modernKpiCard('Sensores', sensorCount, DashboardColors.primary)),
            const SizedBox(width: 8),
            Expanded(child: DeviceDetailHelpers.modernKpiCard('Alertas', alerts, DashboardColors.error)),
            const SizedBox(width: 8),
            Expanded(child: DeviceDetailHelpers.modernKpiCard('Advertencias', warnings, DashboardColors.warning)),
          ],
        ),
        if (pending != null && pending! > 0) ...[
          const SizedBox(height: 8),
          DeviceDetailHelpers.modernKpiCard('Pendientes', pending!, DashboardColors.info, fullWidth: true),
        ],
      ],
    );
  }
}
