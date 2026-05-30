import 'package:flutter/material.dart';
import '../define_sensor_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


/// Step 2a: Confirm sensor activation (reserve flow)
class ConfirmStepWidget extends StatelessWidget {
  const ConfirmStepWidget({
    super.key,
    required this.reserveData,
    required this.onConfirm,
    required this.onRetry,
    required this.isLoading,
    required this.error,
  });

  final dynamic reserveData;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Token de confirmación
        Container(
          padding: EdgeInsets.all(DesignSpacing.lg),
          decoration: BoxDecoration(
            color: DesignColors.cyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(color: DesignColors.cyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.verified_user, color: Colors.tealAccent, size: 48),
              SizedBox(height: DesignSpacing.lg),
              Text(
                'Sensor Reservado',
                style: TextStyle(color: DesignColors.textPrimary, fontSize: 14),
              ),
              SizedBox(height: DesignSpacing.sm),
              Text(
                reserveData.sensorType.toUpperCase(),
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: DesignSpacing.sm),
              Text(
                'Dispositivo: ${reserveData.deviceName}',
                style: TextStyle(color: DesignColors.textPrimary, fontSize: 14),
              ),
              SizedBox(height: DesignSpacing.md),
              if (reserveData.requireQrConfirmation && reserveData.qrData != null)
                Container(
                  padding: EdgeInsets.all(DesignSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: const Text(
                    'QR para confirmación cruzada',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: DesignSpacing.lg),

        // Info de confirmación
        Container(
          padding: EdgeInsets.all(DesignSpacing.lg),
          decoration: BoxDecoration(
            color: DesignColors.border,
            borderRadius: BorderRadius.circular(DesignRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirme para activar el sensor:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: DesignSpacing.md),
              DefineSensorWidgets.usageOption(Icons.check_circle, 'Botón', 'Presione "Confirmar Activación"'),
              DefineSensorWidgets.usageOption(Icons.memory, 'Firmware', 'POST /devices/sensors/confirm'),
              DefineSensorWidgets.usageOption(Icons.warning_amber, 'Importante', '⚠️ El API Key solo se muestra una vez'),
            ],
          ),
        ),
        SizedBox(height: DesignSpacing.lg),

        if (error != null) ...[
          DefineSensorWidgets.errorWidget(error!),
          SizedBox(height: DesignSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar confirmación'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.tealAccent,
                side: const BorderSide(color: Colors.tealAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)),
              ),
            ),
          ),
        ],

        // Confirmar activación
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onConfirm,
            icon: isLoading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.check),
            label: Text(isLoading ? 'Confirmando...' : 'Confirmar Activación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
