import 'package:flutter/material.dart';
import 'raw_readings/raw_sensor_readings_page.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


/// Widget de acceso a lecturas crudas por sensor
/// 
/// FASE 3.1 ACTUALIZADO: Ahora navega a una pantalla dedicada con lista de sensores.
/// Solo datos raw, sin estados, sin alertas, sin ML.
/// Gráfica simple, limpia. Ideal para diagnóstico.
class RawReadingsChart extends StatelessWidget {
  const RawReadingsChart({
    super.key,
    required this.sensors,
    this.deviceId,
    this.deviceName,
    this.initialSensorId,
  });

  /// Lista de sensores disponibles (id, nombre, unit)
  final List<({String id, String name, String? unit})> sensors;
  
  /// ID del dispositivo (para navegación)
  final String? deviceId;
  
  /// Nombre del dispositivo (para navegación)
  final String? deviceName;
  
  /// Sensor seleccionado inicialmente (legacy, no usado en nueva navegación)
  final String? initialSensorId;

  @override
  Widget build(BuildContext context) {
    if (sensors.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Text(
            'Sin sensores disponibles',
            style: DesignTextStyles.bodyText,
          ),
        ),
      );
    }

    // Contar sensores activos (todos los que llegan aquí se consideran activos)
    final activeSensorCount = sensors.length;

    return Card(
      child: InkWell(
        onTap: () => _navigateToRawReadings(context),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                  border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: Colors.tealAccent,
                  size: 24,
                ),
              ),
              SizedBox(width: DesignSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lecturas Crudas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      '$activeSensorCount sensor${activeSensorCount != 1 ? 'es' : ''} disponible${activeSensorCount != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: DesignColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRawReadings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RawSensorReadingsPage(
          deviceId: deviceId ?? '',
          deviceName: deviceName ?? 'Dispositivo',
          sensors: sensors,
        ),
      ),
    );
  }
}
