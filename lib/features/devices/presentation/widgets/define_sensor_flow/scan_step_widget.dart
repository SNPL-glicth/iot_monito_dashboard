import 'package:flutter/material.dart';
import '../sensor_types_config.dart';
import '../define_sensor_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


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
          padding: EdgeInsets.all(DesignSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.tealAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(SensorTypesConfig.getIcon(selectedType), color: Colors.tealAccent, size: 32),
              SizedBox(width: DesignSpacing.md),
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
                      style: TextStyle(color: DesignColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.greenAccent),
            ],
          ),
        ),
        SizedBox(height: DesignSpacing.xl),

        // Instrucciones
        Container(
          padding: EdgeInsets.all(DesignSpacing.lg),
          decoration: BoxDecoration(
            color: DesignColors.cyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(color: DesignColors.cyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.qr_code_scanner, color: Colors.blueAccent, size: 48),
              SizedBox(height: DesignSpacing.lg),
              const Text(
                'Escanee el código QR del sensor físico',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: DesignSpacing.sm),
              Text(
                'El QR está impreso en el hardware del sensor y contiene su identificador único.',
                textAlign: TextAlign.center,
                style: TextStyle(color: DesignColors.textPrimary),
              ),
            ],
          ),
        ),
        SizedBox(height: DesignSpacing.xl),

        if (error != null)
          DefineSensorWidgets.errorWidget(error!),

        // Botón para escanear
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onOpenScanner,
            icon: isLoading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.camera_alt),
            label: Text(isLoading ? 'Activando...' : 'Abrir Cámara'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: DesignSpacing.lg),

        // Opción manual para testing
        OutlinedButton.icon(
          onPressed: isLoading ? null : onManualCode,
          icon: const Icon(Icons.keyboard),
          label: const Text('Ingresar código manualmente'),
          style: OutlinedButton.styleFrom(
            foregroundColor: DesignColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
