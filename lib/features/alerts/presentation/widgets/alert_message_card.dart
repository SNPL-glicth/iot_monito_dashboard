import 'package:flutter/material.dart';

import '../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Tarjeta de mensaje adicional de una alerta
class AlertMessageCard extends StatelessWidget {
  const AlertMessageCard({
    super.key,
    required this.message,
  });

  final String message;

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
                const Icon(Icons.info_outline, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  'Información adicional',
                  style: DashboardTextStyles.deviceTitle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: DashboardTextStyles.sensorMeta,
            ),
          ],
        ),
      ),
    );
  }
}
