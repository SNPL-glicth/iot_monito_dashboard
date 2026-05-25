import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../sensor_types_config.dart';
import '../define_sensor_widgets.dart';

/// Step 1: Choose activation method (QR or Reserve)
class ChooseMethodStepWidget extends StatelessWidget {
  const ChooseMethodStepWidget({
    super.key,
    required this.selectedType,
    required this.publishDone,
    required this.reserveDone,
    required this.onQRSelected,
    required this.onPublishSelected,
    required this.onReserveSelected,
    required this.onRetryReserve,
    required this.isLoading,
    required this.error,
  });

  final String selectedType;
  final bool publishDone;
  final bool reserveDone;
  final VoidCallback onQRSelected;
  final VoidCallback onPublishSelected;
  final VoidCallback onReserveSelected;
  final VoidCallback onRetryReserve;
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

        // Opción 2: Flujo publish → reserve → confirm
        if (!publishDone) ...[
          DefineSensorWidgets.methodCard(
            icon: Icons.cloud_upload,
            title: '1. Publicar sensor',
            description: 'Hace el sensor disponible para ser reclamado (PENDING_CLAIM).',
            color: Colors.tealAccent,
            onTap: onPublishSelected,
            isLoading: isLoading,
          ),
        ] else ...[
          _successTile(
            icon: Icons.check_circle,
            title: 'Publicado correctamente',
            subtitle: 'El sensor está en estado PENDING_CLAIM.',
          ),
          const SizedBox(height: 12),
          if (!reserveDone) ...[
            DefineSensorWidgets.methodCard(
              icon: Icons.link,
              title: '2. Reservar sensor',
              description: 'Reserva el sensor y genera el claim token.',
              color: Colors.tealAccent,
              onTap: onReserveSelected,
              isLoading: isLoading,
            ),
          ] else ...[
            _successTile(
              icon: Icons.check_circle,
              title: 'Reservado correctamente',
              subtitle: 'Claim token generado.',
            ),
          ],
        ],
        const SizedBox(height: 16),

        if (error != null) ...[
          DefineSensorWidgets.errorWidget(error!),
          const SizedBox(height: 12),
          if (publishDone && !reserveDone)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onRetryReserve,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar reserva'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.tealAccent,
                  side: const BorderSide(color: Colors.tealAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _successTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardColors.greenAccent10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.greenAccent30),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: DashboardColors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
