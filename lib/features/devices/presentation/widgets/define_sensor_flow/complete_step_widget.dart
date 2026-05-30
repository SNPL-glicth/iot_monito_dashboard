import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


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
        SizedBox(height: 32),
        Container(
          padding: EdgeInsets.all(DesignSpacing.xl),
          decoration: BoxDecoration(
            color: DesignColors.green.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 64, color: Colors.greenAccent),
        ),
        SizedBox(height: DesignSpacing.xl),
        const Text(
          '¡Sensor Activado!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: DesignSpacing.md),
        Text(
          'El sensor está listo para recibir datos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: DesignColors.textPrimary),
        ),
        
        // Mostrar API Key si viene del flujo reserve → confirm
        if (confirmResult != null) ...[
          SizedBox(height: DesignSpacing.xl),
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(
              color: DesignColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignRadius.md),
              border: Border.all(color: DesignColors.amber.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: DesignColors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '⚠️ API Key del Sensor',
                      style: TextStyle(color: DesignColors.amber, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  'Guarde este API Key de forma segura. NO se mostrará de nuevo.',
                  style: TextStyle(color: DesignColors.textPrimary, fontSize: 12),
                ),
                SizedBox(height: DesignSpacing.md),
                Container(
                  padding: EdgeInsets.all(DesignSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
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
        
        SizedBox(height: 32),

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
