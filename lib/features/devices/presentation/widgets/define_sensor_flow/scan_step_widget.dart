import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../sensor_types_config.dart';
import '../define_sensor_widgets.dart';

/// Step 2b: Scan QR of physical sensor
class ScanStepWidget extends StatelessWidget {
  const ScanStepWidget({
    super.key,
    required this.selectedType,
    required this.onOpenScanner,
    required this.onManualCode,
    required this.isLoading,
    required this.error,
  });

  final String selectedType;
  final VoidCallback onOpenScanner;
  final VoidCallback onManualCode;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Información del sensor definido
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.tealAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(SensorTypesConfig.getIcon(selectedType), color: Colors.tealAccent, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensor: ${SensorTypesConfig.getLabel(selectedType)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Unidad: ${SensorTypesConfig.getUnit(selectedType)}',
                      style: const TextStyle(color: DashboardColors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.greenAccent),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Instrucciones
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DashboardColors.blueAccent10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DashboardColors.blueAccent30),
          ),
          child: Column(
            children: [
              const Icon(Icons.qr_code_scanner, color: Colors.blueAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Escanee el código QR del sensor físico',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'El QR está impreso en el hardware del sensor y contiene su identificador único.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: DashboardColors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (error != null)
          DefineSensorWidgets.errorWidget(error!),

        // Botón para escanear
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onOpenScanner,
            icon: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.camera_alt),
            label: Text(isLoading ? 'Activando...' : 'Abrir Cámara'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Opción manual para testing
        OutlinedButton.icon(
          onPressed: isLoading ? null : onManualCode,
          icon: const Icon(Icons.keyboard),
          label: const Text('Ingresar código manualmente'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
          ),
        ),
      ],
    );
  }
}
