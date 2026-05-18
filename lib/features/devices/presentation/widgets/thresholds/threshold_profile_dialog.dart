import 'package:flutter/material.dart';

import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';
import '../../../../../features/monitoring/data/monitoring_repository.dart';
import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Diálogo para editar el perfil de umbrales de un sensor.
Future<void> showThresholdProfileDialog({
  required BuildContext context,
  required MonitoringRepository repo,
  required String sensorId,
  required String sensorName,
  required String unit,
  required SensorThresholdProfileViewModel profile,
  required VoidCallback onSaved,
}) async {
  final warningMinCtrl = TextEditingController(text: profile.warningMin ?? '');
  final warningMaxCtrl = TextEditingController(text: profile.warningMax ?? '');
  final alertMinCtrl = TextEditingController(text: profile.alertMin ?? '');
  final alertMaxCtrl = TextEditingController(text: profile.alertMax ?? '');
  final cooldownCtrl = TextEditingController(text: profile.cooldownSeconds.toString());

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Perfil de umbrales', style: DashboardTextStyles.deviceTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sensor: $sensorName ($unit)', style: DashboardTextStyles.sensorMeta),
            const SizedBox(height: 12),
            const Text('WARNING (fuera de rango leve)', style: DashboardTextStyles.smallLabel),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: warningMinCtrl,
                    decoration: const InputDecoration(labelText: 'warning_min', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: warningMaxCtrl,
                    decoration: const InputDecoration(labelText: 'warning_max', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('ALERT (fuera de rango crítico)', style: DashboardTextStyles.smallLabel),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: alertMinCtrl,
                    decoration: const InputDecoration(labelText: 'alert_min', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: alertMaxCtrl,
                    decoration: const InputDecoration(labelText: 'alert_max', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cooldownCtrl,
              decoration: const InputDecoration(
                labelText: 'cooldown_seconds',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const Text(
              'Regla: se generan eventos solo al CRUZAR umbral; el cooldown evita repetición.',
              style: DashboardTextStyles.sensorMeta,
            ),
          ],
        ),
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
    final cd = int.tryParse(cooldownCtrl.text.trim());
    await repo.updateSensorThresholdProfile(
      sensorId,
      warningMin: warningMinCtrl.text.trim(),
      warningMax: warningMaxCtrl.text.trim(),
      alertMin: alertMinCtrl.text.trim(),
      alertMax: alertMaxCtrl.text.trim(),
      cooldownSeconds: cd,
    );
    onSaved();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el perfil: $e')),
      );
    }
  }
}
