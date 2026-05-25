import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../define_sensor_widgets.dart';

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DashboardColors.tealAccent10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DashboardColors.tealAccent30),
          ),
          child: Column(
            children: [
              const Icon(Icons.verified_user, color: Colors.tealAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Sensor Reservado',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                reserveData.sensorType.toUpperCase(),
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dispositivo: ${reserveData.deviceName}',
                style: const TextStyle(color: DashboardColors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              if (reserveData.requireQrConfirmation && reserveData.qrData != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'QR para confirmación cruzada',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Info de confirmación
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DashboardColors.white05,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirme para activar el sensor:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              DefineSensorWidgets.usageOption(Icons.check_circle, 'Botón', 'Presione "Confirmar Activación"'),
              DefineSensorWidgets.usageOption(Icons.memory, 'Firmware', 'POST /devices/sensors/confirm'),
              DefineSensorWidgets.usageOption(Icons.warning_amber, 'Importante', '⚠️ El API Key solo se muestra una vez'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (error != null) ...[
          DefineSensorWidgets.errorWidget(error!),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar confirmación'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.tealAccent,
                side: const BorderSide(color: Colors.tealAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
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
