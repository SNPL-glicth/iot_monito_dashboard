import 'package:flutter/material.dart';

import '../../../../core/alerts/alert_snapshot_service.dart';
import '../../../../core/auth/user_role.dart';
import '../../../crm/data/crm_repository.dart';
import 'alert_detail_actions.dart';
import 'alert_detail_widgets.dart';
import 'alert_header_card.dart';
import 'alert_chart_card.dart';
import 'alert_message_card.dart';
import '../../../../core/theme/design_spacing.dart';

/// Body de la página de detalle de alerta con acciones ack/resolve.
class AlertDetailBody extends StatelessWidget {
  const AlertDetailBody({
    super.key,
    required this.snapshot,
    required this.role,
    required this.alertId,
    required this.crmRepo,
    required this.acknowledging,
    required this.isAcknowledged,
    required this.onAcknowledgeChanged,
    required this.resolving,
    required this.isResolved,
    required this.onResolveChanged,
    required this.onOptimisticAck,
    required this.onRevertAck,
    required this.onOptimisticResolve,
    required this.onRevertResolve,
  });

  final AlertSnapshot snapshot;
  final UserRole role;
  final String alertId;
  final CrmRepository crmRepo;
  final bool acknowledging;
  final bool isAcknowledged;
  final ValueChanged<bool> onAcknowledgeChanged;
  final bool resolving;
  final bool isResolved;
  final ValueChanged<bool> onResolveChanged;
  final VoidCallback onOptimisticAck;
  final VoidCallback onRevertAck;
  final VoidCallback onOptimisticResolve;
  final VoidCallback onRevertResolve;

  @override
  Widget build(BuildContext context) {
    final canAct = AlertDetailActions.canAcknowledge(role);

    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlertHeaderCard(snapshot: snapshot),
          SizedBox(height: 16),
          AlertChartCard(snapshot: snapshot),
          SizedBox(height: 16),
          if (snapshot.message != null && snapshot.message!.isNotEmpty)
            AlertMessageCard(message: snapshot.message!),
          if (canAct) ...[
            SizedBox(height: 16),
            _ActionButton(
              active: isAcknowledged,
              loading: acknowledging,
              activeLabel: 'ALERTA ATENDIDA',
              inactiveLabel: 'MARCAR COMO ATENDIDA',
              activeColor: Colors.green,
              inactiveColor: Colors.tealAccent,
              onPressed: () => AlertDetailActions.showAcknowledgeConfirmation(
                context,
                () => AlertDetailActions.acknowledgeAlert(
                  alertId,
                  crmRepo,
                  context,
                  onOptimistic: onOptimisticAck,
                  onRevert: onRevertAck,
                  onLoading: onAcknowledgeChanged,
                ),
              ),
            ),
            SizedBox(height: 12),
            _ActionButton(
              active: isResolved,
              loading: resolving,
              activeLabel: 'ALERTA RESUELTA',
              inactiveLabel: 'MARCAR COMO RESUELTA',
              activeColor: Colors.blue,
              inactiveColor: Colors.greenAccent,
              onPressed: () => AlertDetailActions.showResolveConfirmation(
                context,
                () => AlertDetailActions.resolveAlert(
                  alertId,
                  crmRepo,
                  context,
                  onOptimistic: onOptimisticResolve,
                  onRevert: onRevertResolve,
                  onLoading: onResolveChanged,
                ),
              ),
            ),
          ],
          SizedBox(height: 24),
          AlertDetailWidgets.frozenNote(),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.active,
    required this.loading,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.activeColor,
    required this.inactiveColor,
    required this.onPressed,
  });

  final bool active;
  final bool loading;
  final String activeLabel;
  final String inactiveLabel;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(active ? Icons.check_circle : Icons.check_circle_outline),
        label: Text(active ? activeLabel : inactiveLabel),
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? activeColor.withValues(alpha: 0.3) : inactiveColor.withValues(alpha: 0.2),
          foregroundColor: active ? activeColor : inactiveColor,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.sm),
            side: BorderSide(color: (active ? activeColor : inactiveColor).withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }
}
