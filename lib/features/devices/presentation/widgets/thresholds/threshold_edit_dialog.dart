import 'package:flutter/material.dart';
import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';
import '../../../../../features/monitoring/data/monitoring_repository.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Diálogo para editar un umbral legacy.
Future<void> showThresholdEditDialog({
  required BuildContext context,
  required MonitoringRepository repo,
  required String sensorName,
  required String unit,
  required AlertThresholdViewModel threshold,
  required VoidCallback onSaved,
}) async {
  final needsRange = threshold.conditionType == 'out_of_range';
  final minLabel = needsRange ? 'Mínimo' : 'Valor umbral';
  final minCtrl = TextEditingController(text: threshold.thresholdValueMin ?? '');
  final maxCtrl = TextEditingController(text: threshold.thresholdValueMax ?? '');
  final reasonCtrl = TextEditingController();

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Editar límite', style: DesignTextStyles.cardTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sensor: $sensorName ($unit)', style: DesignTextStyles.bodyText),
          Text('Condición: ${threshold.conditionType}', style: DesignTextStyles.bodyText),
          SizedBox(height: DesignSpacing.md),
          TextField(
            controller: minCtrl,
            decoration: InputDecoration(
              labelText: minLabel,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          if (needsRange) ...[
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
          SizedBox(height: DesignSpacing.sm),
          TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(
              labelText: 'Razón del cambio (recomendado)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );

  if (ok != true) return;

  try {
    await repo.updateThreshold(
      threshold.id,
      thresholdValueMin: minCtrl.text.trim(),
      thresholdValueMax: needsRange ? maxCtrl.text.trim() : null,
      reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
    );
    onSaved();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el límite: $e')),
      );
    }
  }
}
