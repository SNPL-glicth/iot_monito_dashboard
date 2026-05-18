import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../sensor_types_config.dart';
import '../define_sensor_widgets.dart';

/// Step 0: Define sensor metrics and thresholds
class DefineStepWidget extends StatelessWidget {
  const DefineStepWidget({
    super.key,
    required this.formKey,
    required this.selectedType,
    required this.warningMinController,
    required this.warningMaxController,
    required this.alertMinController,
    required this.alertMaxController,
    required this.onTypeSelected,
    required this.onNext,
    required this.isLoading,
    required this.error,
  });

  final GlobalKey<FormState> formKey;
  final String selectedType;
  final TextEditingController warningMinController;
  final TextEditingController warningMaxController;
  final TextEditingController alertMinController;
  final TextEditingController alertMaxController;
  final Function(String) onTypeSelected;
  final VoidCallback onNext;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleccione el tipo de sensor y configure los umbrales.',
            style: TextStyle(color: DashboardColors.white70),
          ),
          const SizedBox(height: 20),

          // Selector de tipo
          const Text('Tipo de sensor', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SensorTypesConfig.sensorTypes.map((type) {
              final isSelected = selectedType == type['type'];
              return ChoiceChip(
                avatar: Icon(type['icon'] as IconData, size: 18),
                label: Text(type['label'] as String),
                selected: isSelected,
                onSelected: (_) => onTypeSelected(type['type'] as String),
                selectedColor: Colors.tealAccent,
                backgroundColor: Colors.grey[800],
                labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Unidad (automática)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DashboardColors.white05,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.straighten, color: Colors.tealAccent, size: 20),
                const SizedBox(width: 12),
                const Text('Unidad: ', style: TextStyle(color: Colors.white70)),
                Text(
                  SensorTypesConfig.getUnit(selectedType),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Umbrales
          DefineSensorWidgets.thresholdSection(
            title: 'Umbral de Advertencia',
            color: Colors.orangeAccent,
            minController: warningMinController,
            maxController: warningMaxController,
          ),
          const SizedBox(height: 16),
          DefineSensorWidgets.thresholdSection(
            title: 'Umbral de Alerta',
            color: Colors.redAccent,
            minController: alertMinController,
            maxController: alertMaxController,
          ),
          const SizedBox(height: 24),

          // Error
          if (error != null)
            DefineSensorWidgets.errorWidget(error!),

          // Botón siguiente
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onNext,
              icon: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.arrow_forward),
              label: Text(isLoading ? 'Definiendo...' : 'Siguiente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
