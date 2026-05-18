import 'package:flutter/material.dart';

import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';
import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Tarjeta con el perfil de umbrales recomendado y botón de edición.
class ThresholdProfileCard extends StatelessWidget {
  const ThresholdProfileCard({
    super.key,
    required this.future,
    required this.unit,
    required this.canEdit,
    required this.onEdit,
  });

  final Future<SensorThresholdProfileViewModel> future;
  final String unit;
  final bool canEdit;
  final void Function(SensorThresholdProfileViewModel) onEdit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SensorThresholdProfileViewModel>(
      future: future,
      builder: (context, pSnap) {
        final p = pSnap.data;
        if (pSnap.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (pSnap.hasError || p == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error cargando perfil: ${pSnap.error}',
                style: DashboardTextStyles.error,
              ),
            ),
          );
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.tune, color: Colors.tealAccent),
            title: const Text('Perfil de umbrales (recomendado)', style: DashboardTextStyles.deviceTitle),
            subtitle: Text(
              'WARNING: ${p.warningMin ?? '-'} – ${p.warningMax ?? '-'} $unit\n'
              'ALERT: ${p.alertMin ?? '-'} – ${p.alertMax ?? '-'} $unit\n'
              'Cooldown: ${p.cooldownSeconds}s',
              style: DashboardTextStyles.sensorMeta,
            ),
            trailing: canEdit
                ? IconButton(
                    onPressed: () => onEdit(p),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar perfil',
                  )
                : null,
          ),
        );
      },
    );
  }
}
