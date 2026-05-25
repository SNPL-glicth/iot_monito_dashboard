import 'package:flutter/material.dart';

import '../../styles/dashboard_styles.dart';

class RawDiagnosisErrorWidget extends StatelessWidget {
  const RawDiagnosisErrorWidget({
    super.key,
    required this.statusCode,
    required this.message,
    required this.onRetry,
  });

  final int? statusCode;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DashboardColors.redAccent15,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.error_outline, size: 40, color: DashboardColors.error),
            ),
            const SizedBox(height: 20),
            Text('Error al cargar datos', style: DashboardTextStyles.deviceTitle),
            const SizedBox(height: 8),
            if (statusCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DashboardColors.redAccent15,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DashboardColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'HTTP $statusCode',
                  style: TextStyle(color: DashboardColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 12),
            Text(message, style: DashboardTextStyles.sensorMeta, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
