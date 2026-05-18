import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Botón de activación del dispositivo (solo cuando está en DRAFT o PENDING_ACTIVATION).
class DeviceActivationButton extends StatelessWidget {
  const DeviceActivationButton({
    super.key,
    required this.deviceStatus,
    required this.deviceUuid,
    required this.deviceName,
    required this.onActivate,
  });

  final String deviceStatus;
  final String deviceUuid;
  final String deviceName;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final isDraft = deviceStatus.toLowerCase() == 'draft';

    return Container(
      width: double.infinity,
      decoration: ModernCardDecoration.elevated(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isDraft ? onActivate : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDraft ? Icons.qr_code_rounded : Icons.hourglass_empty_rounded,
                  color: isDraft ? DashboardColors.primary : DashboardColors.warning,
                ),
                const SizedBox(width: 12),
                Text(
                  isDraft ? 'Activar Dispositivo' : 'Esperando activación',
                  style: TextStyle(
                    color: isDraft ? DashboardColors.primary : DashboardColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
