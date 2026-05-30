import 'package:flutter/material.dart';
import '../sensor_types_config.dart';
import '../define_sensor_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


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
          Text(
            'Seleccione el tipo de sensor y configure los umbrales.',
            style: TextStyle(color: DesignColors.textPrimary),
          ),
          SizedBox(height: DesignSpacing.lg),

          // Selector de tipo
          Text('Tipo de sensor', style: TextStyle(color: DesignColors.textPrimary, fontSize: 12)),
          SizedBox(height: DesignSpacing.sm),
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
          SizedBox(height: DesignSpacing.xl),

          // Unidad (automática)
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: DesignColors.border,
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Row(
              children: [
                const Icon(Icons.straighten, color: Colors.tealAccent, size: 20),
                SizedBox(width: DesignSpacing.md),
                Text('Unidad: ', style: TextStyle(color: DesignColors.textPrimary)),
                Text(
                  SensorTypesConfig.getUnit(selectedType),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: DesignSpacing.xl),

          // Umbrales
          DefineSensorWidgets.thresholdSection(
            title: 'Umbral de Advertencia',
            color: DesignColors.amber,
            minController: warningMinController,
            maxController: warningMaxController,
          ),
          SizedBox(height: DesignSpacing.lg),
          DefineSensorWidgets.thresholdSection(
            title: 'Umbral de Alerta',
            color: DesignColors.red,
            minController: alertMinController,
            maxController: alertMaxController,
          ),
          SizedBox(height: DesignSpacing.xl),

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
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.arrow_forward),
              label: Text(isLoading ? 'Definiendo...' : 'Siguiente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
              ),
            ),
          ),
          SizedBox(height: DesignSpacing.lg),
        ],
      ),
    );
  }
}
