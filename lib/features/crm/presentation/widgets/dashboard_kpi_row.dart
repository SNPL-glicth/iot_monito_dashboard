import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/kpi_card.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../data/models/crm_dashboard_models.dart';

class DashboardKpiRow extends StatelessWidget {
  const DashboardKpiRow({super.key, required this.kpis});

  final CrmDashboardKpis kpis;

  int _sum(Map<String, int> m) => m.values.fold(0, (a, b) => a + b);

  int _get(Map<String, int> m, String key) => m[key] ?? 0;

  @override
  Widget build(BuildContext context) {
    final totalDevices = _sum(kpis.devicesByStatus);
    final onlineDevices = _get(kpis.devicesByStatus, 'online') +
        _get(kpis.devicesByStatus, 'running');
    final totalAlerts = _sum(kpis.activeAlertsBySeverity);
    final criticalAlerts = _get(kpis.activeAlertsBySeverity, 'critical');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final children = [
          KpiCard(
            label: 'Devices',
            value: '$totalDevices',
            unit: 'total',
            accentColor: DesignColors.cyan,
          ),
          KpiCard(
            label: 'Active',
            value: '$onlineDevices',
            unit: 'online',
            accentColor: DesignColors.green,
          ),
          KpiCard(
            label: 'Alerts',
            value: '$totalAlerts',
            unit: 'active',
            accentColor: totalAlerts > 0 ? DesignColors.amber : DesignColors.cyan,
          ),
          KpiCard(
            label: 'Critical',
            value: '$criticalAlerts',
            unit: 'faults',
            accentColor: criticalAlerts > 0 ? DesignColors.red : DesignColors.cyan,
          ),
        ];

        if (isWide) {
          return Row(
            children: children
                .map((c) => Expanded(child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: DesignSpacing.xs),
                      child: c,
                    )))
                .toList(),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: Padding(
                  padding: EdgeInsets.all(DesignSpacing.xs),
                  child: children[0],
                )),
                Expanded(child: Padding(
                  padding: EdgeInsets.all(DesignSpacing.xs),
                  child: children[1],
                )),
              ],
            ),
            Row(
              children: [
                Expanded(child: Padding(
                  padding: EdgeInsets.all(DesignSpacing.xs),
                  child: children[2],
                )),
                Expanded(child: Padding(
                  padding: EdgeInsets.all(DesignSpacing.xs),
                  child: children[3],
                )),
              ],
            ),
          ],
        );
      },
    );
  }
}
