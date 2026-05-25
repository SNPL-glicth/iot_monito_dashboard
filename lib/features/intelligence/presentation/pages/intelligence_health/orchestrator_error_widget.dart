import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Widget de error específico para fallos del orchestrator/diagnóstico ML.
/// Muestra estado del servicio, botón de reintentar y timestamp del último dato válido.
class OrchestratorErrorWidget extends StatelessWidget {
  const OrchestratorErrorWidget({
    super.key,
    required this.errorMessage,
    this.lastKnownPing,
    this.lastValidTimestamp,
    required this.onRetry,
  });

  final String errorMessage;
  final DateTime? lastKnownPing;
  final DateTime? lastValidTimestamp;
  final VoidCallback onRetry;

  String _format(DateTime? dt) {
    if (dt == null) return 'Desconocido';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DashboardColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.cloud_off_rounded, color: DashboardColors.error, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Servicio de diagnóstico no disponible',
              style: DashboardTextStyles.deviceTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: DashboardTextStyles.sensorMeta,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _InfoRow(icon: Icons.network_ping, label: 'Último ping', value: _format(lastKnownPing)),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.access_time, label: 'Último dato válido', value: _format(lastValidTimestamp)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Text('$label: ', style: DashboardTextStyles.sensorMeta),
        Text(value, style: DashboardTextStyles.smallLabel.copyWith(color: Colors.white70)),
      ],
    );
  }
}
