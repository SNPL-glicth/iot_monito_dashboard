import 'package:flutter/material.dart';

import '../../../../core/alerts/alert_snapshot_service.dart';
import '../../../../core/auth/user_role.dart';
import '../../../crm/data/crm_repository.dart';
import 'alert_detail_actions.dart';
import 'alert_detail_widgets.dart';
import 'alert_header_card.dart';
import 'alert_chart_card.dart';
import 'alert_message_card.dart';

/// Body de la página de detalle de alerta.
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
  });

  final AlertSnapshot snapshot;
  final UserRole role;
  final String alertId;
  final CrmRepository crmRepo;
  final bool acknowledging;
  final bool isAcknowledged;
  final ValueChanged<bool> onAcknowledgeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlertHeaderCard(snapshot: snapshot),
          const SizedBox(height: 16),
          AlertChartCard(snapshot: snapshot),
          const SizedBox(height: 16),
          if (snapshot.message != null && snapshot.message!.isNotEmpty)
            AlertMessageCard(message: snapshot.message!),
          if (AlertDetailActions.canAcknowledge(role))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: acknowledging
                      ? null
                      : () => AlertDetailActions.showAcknowledgeConfirmation(
                          context,
                          () => AlertDetailActions.acknowledgeAlert(
                            alertId,
                            crmRepo,
                            context,
                            onStateChanged: onAcknowledgeChanged,
                          ),
                        ),
                  icon: acknowledging
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isAcknowledged ? Icons.check_circle : Icons.check_circle_outline,
                        ),
                  label: Text(isAcknowledged ? 'ALERTA ATENDIDA' : 'MARCAR COMO ATENDIDA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAcknowledged
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.tealAccent.withValues(alpha: 0.2),
                    foregroundColor: isAcknowledged ? Colors.green : Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isAcknowledged
                            ? Colors.green.withValues(alpha: 0.5)
                            : Colors.tealAccent.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          AlertDetailWidgets.frozenNote(),
        ],
      ),
    );
  }
}
