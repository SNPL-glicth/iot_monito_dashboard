import 'package:flutter/material.dart';
import '../device_detail_helpers.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        gradient: isOnline
            ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [DesignColors.green, DesignColors.green.withValues(alpha: 0.7)])
            : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [DesignColors.amber, DesignColors.amber.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignSpacing.md),
                decoration: BoxDecoration(
                  color: DesignColors.textPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                ),
                child: Icon(Icons.memory_rounded, color: DesignColors.textPrimary, size: 28),
              ),
              SizedBox(width: DesignSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: DesignTextStyles.screenTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      '$typeLabel · $deviceStatus',
                      style: TextStyle(
                        color: DesignColors.textPrimary.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),
          Text(
            'Última conexión: $lastConn',
            style: TextStyle(
              color: DesignColors.textPrimary.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
