import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../crm_dashboard_helpers.dart';
import '../../../data/models/crm_dashboard_models.dart';
import 'crm_top_devices_card.dart';

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
                gradient: DashboardColors.gradientPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CrmDashboardHelpers.modernKpiCard(
                icon: Icons.warning_amber_rounded,
                label: 'ALERTAS',
                value: '$totalAlerts',
                subtitle: '$criticalAlerts críticas',
                gradient: totalAlerts > 0
                    ? DashboardColors.gradientError
                    : DashboardColors.gradientSuccess,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CrmDashboardHelpers.statusBreakdownCard(
          title: 'Estado de Dispositivos',
          icon: Icons.router_outlined,
          items: devices,
          colorMap: {
            'online': DashboardColors.success,
            'active': DashboardColors.success,
            'offline': DashboardColors.error,
            'inactive': DashboardColors.warning,
            'maintenance': DashboardColors.info,
          },
        ),
        const SizedBox(height: 12),
        CrmDashboardHelpers.statusBreakdownCard(
          title: 'Alertas por Severidad',
          icon: Icons.notifications_outlined,
          items: alerts,
          colorMap: {
            'critical': DashboardColors.error,
            'warning': DashboardColors.warning,
            'info': DashboardColors.info,
          },
        ),
        const SizedBox(height: 12),
        if (topDevices.isNotEmpty) CrmTopDevicesCard(topDevices: topDevices),
      ],
    );
  }
}
