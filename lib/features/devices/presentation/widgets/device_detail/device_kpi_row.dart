import 'package:flutter/material.dart';
import '../device_detail_helpers.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


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
            Expanded(child: DeviceDetailHelpers.modernKpiCard('Sensores', sensorCount, DesignColors.cyan)),
            SizedBox(width: DesignSpacing.sm),
            Expanded(child: DeviceDetailHelpers.modernKpiCard('Alertas', alerts, DesignColors.red)),
            SizedBox(width: DesignSpacing.sm),
            Expanded(child: DeviceDetailHelpers.modernKpiCard('Advertencias', warnings, DesignColors.amber)),
          ],
        ),
        if (pending != null && pending! > 0) ...[
          SizedBox(height: DesignSpacing.sm),
          DeviceDetailHelpers.modernKpiCard('Pendientes', pending!, DesignColors.cyan, fullWidth: true),
        ],
      ],
    );
  }
}
