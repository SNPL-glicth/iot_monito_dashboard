import 'package:flutter/material.dart';
import '../../../../../features/monitoring/data/monitoring_repository.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Diálogo para crear un nuevo umbral legacy.
Future<void> showThresholdCreateDialog({
  required BuildContext context,
  required MonitoringRepository repo,
  required String sensorId,
  required String sensorName,
  required String unit,
  required VoidCallback onCreated,
}) async {
  final nameCtrl = TextEditingController();
  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();
  final severity = ValueNotifier<String>('warning');
  final condition = ValueNotifier<String>('greater_than');

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Nuevo límite', style: DesignTextStyles.cardTitle),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sensor: $sensorName ($unit)', style: DesignTextStyles.bodyText),
              SizedBox(height: DesignSpacing.md),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: DesignSpacing.sm),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: condition.value,
                decoration: const InputDecoration(
                  labelText: 'Condición',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'greater_than', child: Text('greater_than (>)')),
                  DropdownMenuItem(value: 'less_than', child: Text('less_than (<)')),
                  DropdownMenuItem(value: 'equal_to', child: Text('equal_to (=)')),
                  DropdownMenuItem(value: 'out_of_range', child: Text('out_of_range (min/max)')),
                ],
                onChanged: (v) => setState(() => condition.value = v ?? 'greater_than'),
              ),
              SizedBox(height: DesignSpacing.sm),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: severity.value,
                decoration: const InputDecoration(
                  labelText: 'Severidad',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'info', child: Text('info')),
                  DropdownMenuItem(value: 'warning', child: Text('warning')),
                  DropdownMenuItem(value: 'critical', child: Text('critical')),
                ],
                onChanged: (v) => setState(() => severity.value = v ?? 'warning'),
              ),
              SizedBox(height: DesignSpacing.sm),
              TextField(
                controller: minCtrl,
                decoration: InputDecoration(
                  labelText: condition.value == 'out_of_range' ? 'Mínimo' : 'Valor umbral',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              if (condition.value == 'out_of_range') ...[
                SizedBox(height: DesignSpacing.sm),
                TextField(
                  controller: maxCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Máximo',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Crear'),
        ),
      ],
    ),
  );

  if (ok != true) return;

  try {
    await repo.createSensorThreshold(
      sensorId,
      name: nameCtrl.text.trim().isEmpty ? 'Límite' : nameCtrl.text.trim(),
      conditionType: condition.value,
      thresholdValueMin: minCtrl.text.trim(),
      thresholdValueMax: condition.value == 'out_of_range' ? maxCtrl.text.trim() : '',
      severity: severity.value,
    );
    onCreated();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el límite: $e')),
      );
    }
  }
}
