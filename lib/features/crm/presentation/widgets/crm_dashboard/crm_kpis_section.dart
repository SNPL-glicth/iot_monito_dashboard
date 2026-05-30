import 'package:flutter/material.dart';
import '../crm_dashboard_helpers.dart';
import '../../../data/models/crm_dashboard_models.dart';
import 'crm_top_devices_card.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


/// Sección de KPIs del dashboard CRM con grid y breakdowns.
class CrmKpisSection extends StatelessWidget {
  const CrmKpisSection({
    super.key,
    required this.data,
  });

  final CrmDashboardResponse data;

  @override
  Widget build(BuildContext context) {
    final devices = data.kpis.devicesByStatus;
    final alerts = data.kpis.activeAlertsBySeverity;
    final topDevices = data.topDevicesByActiveAlerts;

    final totalDevices = devices.values.fold(0, (a, b) => a + b);
    final onlineDevices = devices['online'] ?? devices['active'] ?? 0;
    final totalAlerts = alerts.values.fold(0, (a, b) => a + b);
    final criticalAlerts = alerts['critical'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CrmDashboardHelpers.modernKpiCard(
                icon: Icons.devices_outlined,
                label: 'DISPOSITIVOS',
                value: '$totalDevices',
                subtitle: '$onlineDevices online',
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [DesignColors.cyan, DesignColors.cyanDim]),
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: CrmDashboardHelpers.modernKpiCard(
                icon: Icons.warning_amber_rounded,
                label: 'ALERTAS',
                value: '$totalAlerts',
                subtitle: '$criticalAlerts críticas',
                gradient: totalAlerts > 0
                    ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [DesignColors.red, DesignColors.red.withValues(alpha: 0.7)])
                    : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [DesignColors.green, DesignColors.green.withValues(alpha: 0.7)]),
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.md),
        CrmDashboardHelpers.statusBreakdownCard(
          title: 'Estado de Dispositivos',
          icon: Icons.router_outlined,
          items: devices,
          colorMap: {
            'online': DesignColors.green,
            'active': DesignColors.green,
            'offline': DesignColors.red,
            'inactive': DesignColors.amber,
            'maintenance': DesignColors.cyan,
          },
        ),
        SizedBox(height: DesignSpacing.md),
        CrmDashboardHelpers.statusBreakdownCard(
          title: 'Alertas por Severidad',
          icon: Icons.notifications_outlined,
          items: alerts,
          colorMap: {
            'critical': DesignColors.red,
            'warning': DesignColors.amber,
            'info': DesignColors.cyan,
          },
        ),
        SizedBox(height: DesignSpacing.md),
        if (topDevices.isNotEmpty) CrmTopDevicesCard(topDevices: topDevices),
      ],
    );
  }
}
