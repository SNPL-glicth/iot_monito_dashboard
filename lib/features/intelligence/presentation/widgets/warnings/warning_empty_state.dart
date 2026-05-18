import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Estado vacío para la página de advertencias inteligentes.
class WarningEmptyState extends StatelessWidget {
  const WarningEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.tealAccent.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin advertencias activas',
              style: DashboardTextStyles.deviceTitle,
            ),
            const SizedBox(height: 8),
            Text(
              'El sistema de inteligencia artificial no ha detectado\nanomalías o predicciones de riesgo.',
              style: DashboardTextStyles.sensorMeta,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
