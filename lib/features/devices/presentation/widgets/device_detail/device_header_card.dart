import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import '../device_detail_helpers.dart';

/// Header con gradiente del dispositivo.
class DeviceHeaderCard extends StatelessWidget {
  const DeviceHeaderCard({
    super.key,
    required this.deviceName,
    required this.deviceType,
    required this.deviceStatus,
    required this.lastConnection,
  });

  final String deviceName;
  final String deviceType;
  final String deviceStatus;
  final String? lastConnection;

  @override
  Widget build(BuildContext context) {
    final isOnline = deviceStatus.toLowerCase() == 'online';
    final typeLabel = DeviceDetailHelpers.deviceTypeLabel(deviceType);
    final lastConn = DeviceDetailHelpers.formatDateTime(lastConnection);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ModernCardDecoration.gradient(
        isOnline ? DashboardColors.gradientSuccess : DashboardColors.gradientWarning,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.memory_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: DashboardTextStyles.sectionHeader,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$typeLabel · $deviceStatus',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Última conexión: $lastConn',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
