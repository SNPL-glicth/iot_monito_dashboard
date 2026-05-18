import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Estado de error para la página de advertencias inteligentes.
class WarningErrorState extends StatelessWidget {
  const WarningErrorState({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Error cargando advertencias',
              style: DashboardTextStyles.deviceTitle,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: DashboardTextStyles.sensorMeta,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
