import 'package:flutter/material.dart';

import '../../../../core/alerts/alert_snapshot_service.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../widgets/frozen_alert_chart.dart';

/// Tarjeta con la gráfica congelada del contexto de una alerta
class AlertChartCard extends StatelessWidget {
  const AlertChartCard({
    super.key,
    required this.snapshot,
  });

  final AlertSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.tealAccent),
                const SizedBox(width: 8),
                Text(
                  'Contexto de la Alerta',
                  style: DashboardTextStyles.deviceTitle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FrozenAlertChart(snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}
