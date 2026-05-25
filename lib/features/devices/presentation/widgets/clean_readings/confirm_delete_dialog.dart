import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Diálogo de confirmación para eliminar todas las lecturas.
Future<bool> showConfirmDeleteAllDialog(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: DashboardColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DashboardColors.redAccent15,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.delete_forever_rounded, color: DashboardColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Confirmar eliminación', style: DashboardTextStyles.deviceTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Esto eliminará TODAS las lecturas de sensores del sistema.',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DashboardColors.redAccent15,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DashboardColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: DashboardColors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta acción no se puede deshacer.',
                    style: TextStyle(color: DashboardColors.error, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: DashboardColors.white70),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: DashboardColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Eliminar todo'),
        ),
      ],
    ),
  );
  return confirm == true;
}

/// Diálogo de confirmación para eliminar lecturas de un sensor específico.
Future<bool> showConfirmDeleteBySensorDialog(
  BuildContext context, {
  required String sensorLabel,
}) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: DashboardColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DashboardColors.orangeAccent15,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.delete_outline_rounded, color: DashboardColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Confirmar eliminación', style: DashboardTextStyles.deviceTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Se eliminarán permanentemente todas las lecturas del sensor:',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DashboardColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DashboardColors.white10),
            ),
            child: Row(
              children: [
                Icon(Icons.sensors_rounded, color: DashboardColors.primaryLight, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sensorLabel,
                    style: TextStyle(color: DashboardColors.primaryLight, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DashboardColors.redAccent15,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DashboardColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: DashboardColors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta acción no se puede deshacer.',
                    style: TextStyle(color: DashboardColors.error, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: DashboardColors.white70),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: DashboardColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Eliminar lecturas'),
        ),
      ],
    ),
  );
  return confirm == true;
}
