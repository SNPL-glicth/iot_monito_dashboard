import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../sensor_types_config.dart';
import '../define_sensor_widgets.dart';

/// Step 1: Choose activation method (QR or Reserve)
class ChooseMethodStepWidget extends StatelessWidget {
  const ChooseMethodStepWidget({
    super.key,
    required this.selectedType,
    required this.onQRSelected,
    required this.onReserveSelected,
    required this.isLoading,
    required this.error,
  });

  final String selectedType;
  final VoidCallback onQRSelected;
  final VoidCallback onReserveSelected;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info del sensor definido
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DashboardColors.greenAccent10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DashboardColors.greenAccent30),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sensor definido correctamente',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${SensorTypesConfig.getLabel(selectedType)} · ${SensorTypesConfig.getUnit(selectedType)}',
                      style: const TextStyle(color: DashboardColors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          '¿Cómo desea activar el sensor?',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        // Opción 1: Escanear QR
        DefineSensorWidgets.methodCard(
          icon: Icons.qr_code_scanner,
          title: 'Escanear QR del Hardware',
          description: 'Use la cámara para escanear el código QR impreso en el sensor físico.',
          color: Colors.blueAccent,
          onTap: onQRSelected,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),

        // Opción 2: Generar Claim Code
        DefineSensorWidgets.methodCard(
          icon: Icons.link,
          title: 'Reservar y Confirmar',
          description: 'Reserva el sensor y confirma la activación directamente desde la app.',
          color: Colors.tealAccent,
          onTap: onReserveSelected,
          isLoading: isLoading,
        ),
        const SizedBox(height: 16),

        if (error != null)
          DefineSensorWidgets.errorWidget(error!),
      ],
    );
  }
}
