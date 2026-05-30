import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


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
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          onTap: isDraft ? onActivate : null,
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDraft ? Icons.qr_code_rounded : Icons.hourglass_empty_rounded,
                  color: isDraft ? DesignColors.cyan : DesignColors.amber,
                ),
                SizedBox(width: DesignSpacing.md),
                Text(
                  isDraft ? 'Activar Dispositivo' : 'Esperando activación',
                  style: TextStyle(
                    color: isDraft ? DesignColors.cyan : DesignColors.amber,
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
