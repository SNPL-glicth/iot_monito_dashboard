import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/sensor_provisioning_response.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';

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
          padding: EdgeInsets.all(DesignSpacing.lg),
          decoration: BoxDecoration(
            color: DesignColors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(color: DesignColors.green.withValues(alpha: 0.3)),
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
        SizedBox(height: DesignSpacing.lg),
        Text(
          'API KEY DEL SENSOR',
          style: TextStyle(color: DesignColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
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
              SizedBox(width: DesignSpacing.sm),
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
        SizedBox(height: DesignSpacing.xs),
        const Text(
          'Guarda esta API key ahora. Por motivos de seguridad, no podrás volver a verla.',
          style: TextStyle(color: Colors.amberAccent, fontSize: 11, height: 1.4),
        ),
        SizedBox(height: DesignSpacing.lg),
        Text(
          'TOPIC MQTT DE INGESTA',
          style: TextStyle(color: DesignColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.all(DesignSpacing.md),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
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
        SizedBox(height: DesignSpacing.xl),
        ElevatedButton(
          onPressed: onDone,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: const Color(0xFF1E293B),
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
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
