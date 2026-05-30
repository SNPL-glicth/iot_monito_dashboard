import 'package:flutter/material.dart';

import '../../../data/provisioning_repository.dart';
import '../../../../../core/theme/design_colors.dart';

/// Muestra diálogo de confirmación para eliminar un dispositivo.
Future<void> showDeleteDeviceDialog({
  required BuildContext context,
  required ProvisioningRepository provRepo,
  required String deviceId,
  required String deviceName,
  required VoidCallback onDeleted,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Row(
        children: [
          Icon(Icons.warning_amber, color: DesignColors.red),
          SizedBox(width: 8),
          Text('Eliminar dispositivo'),
        ],
      ),
      content: Text(
        '¿Estás seguro de eliminar "$deviceName"?\n\n'
        'Esta acción eliminará también todos sus sensores asociados.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: DesignColors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    try {
      final message = await provRepo.deleteDevice(deviceId: deviceId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop('deleted');
        onDeleted();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: DesignColors.red,
          ),
        );
      }
    }
  }
}
