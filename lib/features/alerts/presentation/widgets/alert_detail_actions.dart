import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../crm/data/crm_repository.dart';

/// Acciones para AlertDetailPage
class AlertDetailActions {
  /// Verifica si el usuario puede marcar la alerta como atendida
  static bool canAcknowledge(UserRole role) {
    return role == UserRole.admin || role == UserRole.operator;
  }

  /// Muestra diálogo de confirmación de acknowledge
  static void showAcknowledgeConfirmation(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text('Confirmar acción'),
        content: const Text(
          '¿Marcar esta alerta como atendida?\n\n'
          'Esto indica que la alerta ha sido revisada y se están tomando acciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirmar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent.withValues(alpha: 0.3),
              foregroundColor: Colors.tealAccent,
            ),
          ),
        ],
      ),
    );
  }

  /// Marca la alerta como atendida
  static Future<void> acknowledgeAlert(
    String alertId,
    CrmRepository crmRepo,
    BuildContext context, {
    required Function(bool) onStateChanged,
  }) async {
    final alertIdInt = int.tryParse(alertId);
    if (alertIdInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de alerta inválido')),
      );
      return;
    }

    onStateChanged(true);

    try {
      await crmRepo.acknowledgeAlert(alertIdInt);
      if (!context.mounted) return;
      onStateChanged(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerta marcada como atendida'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      onStateChanged(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
