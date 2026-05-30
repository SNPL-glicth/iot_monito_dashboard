import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: DesignColors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignRadius.lg),
              ),
              child: Icon(Icons.cloud_off_rounded, color: DesignColors.red, size: 48),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Servicio de diagnóstico no disponible',
              style: DesignTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              errorMessage,
              style: DesignTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xl),
            _InfoRow(icon: Icons.network_ping, label: 'Último ping', value: _format(lastKnownPing)),
            SizedBox(height: DesignSpacing.sm),
            _InfoRow(icon: Icons.access_time, label: 'Último dato válido', value: _format(lastValidTimestamp)),
            SizedBox(height: DesignSpacing.xl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.cyan,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        Icon(icon, size: 16, color: DesignColors.textSecondary),
        SizedBox(width: DesignSpacing.sm),
        Text('$label: ', style: DesignTextStyles.bodyText),
        Text(value, style: DesignTextStyles.timestamp.copyWith(color: DesignColors.textPrimary)),
      ],
    );
  }
}
