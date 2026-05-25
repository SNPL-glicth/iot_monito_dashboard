import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../../data/models/sensor_provisioning_response.dart';

class SuccessStep extends StatelessWidget {
  final SensorProvisioningResponse response;
  final VoidCallback onDone;

  const SuccessStep({
    super.key,
    required this.response,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DashboardColors.greenAccent10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DashboardColors.greenAccent30),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Sensor registrado exitosamente!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'API KEY DEL SENSOR',
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  response.sensorApiKey,
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.tealAccent, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: response.sensorApiKey));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API key copiada al portapapeles'),
                      backgroundColor: Colors.teal,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Copiar API Key',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Guarda esta API key ahora. Por motivos de seguridad, no podrás volver a verla.',
          style: TextStyle(color: Colors.amberAccent, fontSize: 11, height: 1.4),
        ),
        const SizedBox(height: 20),
        const Text(
          'TOPIC MQTT DE INGESTA',
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: SelectableText(
            response.mqttTopic,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onDone,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Listo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
