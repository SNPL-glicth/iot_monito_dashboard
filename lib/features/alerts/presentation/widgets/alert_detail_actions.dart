import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../crm/data/crm_repository.dart';

/// Acciones para AlertDetailPage con optimistic update y revert.
class AlertDetailActions {
  static bool canAcknowledge(UserRole role) {
    return role == UserRole.admin || role == UserRole.operator;
  }

  static bool canResolve(UserRole role) {
    return role == UserRole.admin || role == UserRole.operator;
  }

  static void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
    Color confirmColor = Colors.tealAccent,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: Text(title),
        content: Text(content),
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
              backgroundColor: confirmColor.withValues(alpha: 0.3),
              foregroundColor: confirmColor,
            ),
          ),
        ],
      ),
    );
  }

  static void showAcknowledgeConfirmation(BuildContext context, VoidCallback onConfirm) {
    _showConfirmDialog(
      context,
      title: 'Confirmar acción',
      content: '¿Marcar esta alerta como atendida?\n\n'
          'Esto indica que la alerta ha sido revisada y se están tomando acciones.',
      onConfirm: onConfirm,
    );
  }

  static void showResolveConfirmation(BuildContext context, VoidCallback onConfirm) {
    _showConfirmDialog(
      context,
      title: 'Confirmar resolución',
      content: '¿Marcar esta alerta como resuelta?\n\n'
          'Esto indica que el incidente ha sido solucionado.',
      onConfirm: onConfirm,
      confirmColor: Colors.greenAccent,
    );
  }

  /// Marca la alerta como atendida con optimistic update.
  static Future<void> acknowledgeAlert(
    String alertId,
    CrmRepository crmRepo,
    BuildContext context, {
    required VoidCallback onOptimistic,
    required VoidCallback onRevert,
    required Function(bool) onLoading,
  }) async {
    final alertIdInt = int.tryParse(alertId);
    if (alertIdInt == null) {
      _showSnack(context, 'ID de alerta inválido', isError: true);
      return;
    }

    onOptimistic();
    onLoading(true);

    try {
      await crmRepo.acknowledgeAlert(alertIdInt);
      if (!context.mounted) return;
      onLoading(false);
      _showSnack(context, 'Alerta marcada como atendida');
    } catch (e) {
      if (!context.mounted) return;
      onRevert();
      onLoading(false);
      _showSnack(context, 'Error al atender: $e', isError: true);
    }
  }

  /// Marca la alerta como resuelta con optimistic update.
  static Future<void> resolveAlert(
    String alertId,
    CrmRepository crmRepo,
    BuildContext context, {
    required VoidCallback onOptimistic,
    required VoidCallback onRevert,
    required Function(bool) onLoading,
  }) async {
    final alertIdInt = int.tryParse(alertId);
    if (alertIdInt == null) {
      _showSnack(context, 'ID de alerta inválido', isError: true);
      return;
    }

    onOptimistic();
    onLoading(true);

    try {
      await crmRepo.resolveAlert(alertIdInt);
      if (!context.mounted) return;
      onLoading(false);
      _showSnack(context, 'Alerta resuelta');
    } catch (e) {
      if (!context.mounted) return;
      onRevert();
      onLoading(false);
      _showSnack(context, 'Error al resolver: $e', isError: true);
    }
  }

  static void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }
}
