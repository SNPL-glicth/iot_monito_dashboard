import 'package:flutter/material.dart';
import '../../../../core/alerts/alert_snapshot_service.dart';
import '../widgets/frozen_alert_chart.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


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
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.tealAccent),
                SizedBox(width: DesignSpacing.sm),
                Text(
                  'Contexto de la Alerta',
                  style: DesignTextStyles.cardTitle,
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.lg),
            FrozenAlertChart(snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}
