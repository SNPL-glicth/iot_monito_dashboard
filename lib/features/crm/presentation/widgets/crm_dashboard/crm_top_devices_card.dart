import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../../data/models/crm_dashboard_models.dart';

/// Card de dispositivos prioritarios por cantidad de alertas activas.
class CrmTopDevicesCard extends StatelessWidget {
  const CrmTopDevicesCard({
    super.key,
    required this.topDevices,
  });

  final List<CrmTopDeviceByActiveAlerts> topDevices;

  @override
  Widget build(BuildContext context) {
    final items = topDevices.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: DashboardColors.warning, size: 20),
              const SizedBox(width: 10),
              Text('Dispositivos Prioritarios', style: DashboardTextStyles.deviceTitle),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final d = entry.value;
            final isFirst = idx == 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? DashboardColors.warning.withValues(alpha: 0.2)
                          : DashboardColors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: isFirst ? DashboardColors.warning : Colors.white54,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      d.deviceName,
                      style: DashboardTextStyles.sensorTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: DashboardColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${d.activeAlerts} alertas',
                      style: DashboardTextStyles.smallLabel.copyWith(
                        color: DashboardColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
