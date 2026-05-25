import 'package:flutter/material.dart';
import '../define_sensor_widgets.dart';

class ChooseMethodStep extends StatelessWidget {
  final VoidCallback onManualSelected;

  const ChooseMethodStep({
    super.key,
    required this.onManualSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Selecciona el método de activación',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        DefineSensorWidgets.methodCard(
          icon: Icons.settings,
          title: 'Configuración manual',
          description: 'Registra el sensor e ingresa la API key en tu gateway.',
          color: Colors.tealAccent,
          onTap: onManualSelected,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: 0.4,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code, color: Colors.grey, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Código QR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Próximamente',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock_outline, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
