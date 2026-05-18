import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Step 3: Complete - show success and API key
class CompleteStepWidget extends StatelessWidget {
  const CompleteStepWidget({
    super.key,
    required this.confirmResult,
    required this.onFinish,
  });

  final dynamic confirmResult;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: DashboardColors.greenAccent15,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 64, color: Colors.greenAccent),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Sensor Activado!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          'El sensor está listo para recibir datos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: DashboardColors.white70),
        ),
        
        // Mostrar API Key si viene del flujo reserve → confirm
        if (confirmResult != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DashboardColors.orangeAccent15,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DashboardColors.orangeAccent50),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orangeAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '⚠️ API Key del Sensor',
                      style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Guarde este API Key de forma segura. NO se mostrará de nuevo.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    confirmResult.sensorApiKey,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onFinish,
            icon: const Icon(Icons.done),
            label: const Text('Finalizar'),
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
