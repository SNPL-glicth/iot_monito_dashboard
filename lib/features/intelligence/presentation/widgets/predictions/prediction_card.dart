import 'package:flutter/material.dart';

import '../../../../../core/theme/zenin_colors.dart';
import '../../../data/intelligence_models.dart';
import '../../../domain/prediction_severity.dart';
import 'mini_sparkline.dart';

/// Tarjeta de predicción del sistema Zenin IoT.
///
/// Diseño: header + valor/sparkline + barra de anomalía + meta row + acción.
class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.prediction,
    required this.formatDateTime,
    this.onViewHistory,
  });

  final PredictionSummaryViewModel prediction;
  final String Function(String) formatDateTime;
  final VoidCallback? onViewHistory;

  // --- Mapeo de tipo de sensor a ícono y color ---
  static (IconData, Color) _sensorTypeStyle(String sensorType) {
    final t = sensorType.toLowerCase();
    if (t.contains('temp')) return (Icons.thermostat, ZeninColors.amber);
    if (t.contains('hum')) return (Icons.water_drop, ZeninColors.green);
    if (t.contains('pres')) return (Icons.speed, ZeninColors.blue);
    if (t.contains('elect') || t.contains('volt') || t.contains('amp')) {
      return (Icons.bolt, ZeninColors.purple);
    }
    return (Icons.memory, ZeninColors.grey);
  }

  // --- Mapeo de severidad a badge y color ---
  static (String, Color) _severityBadge(SeverityLevel level) {
    switch (level) {
      case SeverityLevel.critical:
        return ('CRÍTICO', ZeninColors.red);
      case SeverityLevel.high:
      case SeverityLevel.medium:
        return ('ADVERTENCIA', ZeninColors.amber);
      case SeverityLevel.low:
      case SeverityLevel.none:
        return ('NORMAL', ZeninColors.green);
    }
  }

  // --- Color de tendencia ascendente según severidad ---
  static Color _upTrendColor(SeverityLevel level) {
    return (level == SeverityLevel.critical || level == SeverityLevel.high)
        ? ZeninColors.red
        : ZeninColors.amber;
  }

  // --- Color de anomalía según score ---
  static Color _anomalyColor(double score) {
    if (score <= 0.20) return ZeninColors.green;
    if (score <= 0.60) return ZeninColors.amber;
    return ZeninColors.red;
  }

  // --- Texto de tendencia ---
  static (IconData, Color, String) _trendInfo(String trend, SeverityLevel level) {
    final t = trend.toLowerCase();
    if (t == 'up') {
      return (Icons.trending_up, _upTrendColor(level), 'Ascendente');
    }
    if (t == 'down') {
      return (Icons.trending_down, ZeninColors.green, 'Descendente');
    }
    return (Icons.remove, ZeninColors.textFaint, 'Estable');
  }

  @override
  Widget build(BuildContext context) {
    final p = prediction;
    final sevLevel = PredictionSeverity.fromString(p.severity);
    final (badgeLabel, badgeColor) = _severityBadge(sevLevel);
    final (sensorIcon, sensorColor) = _sensorTypeStyle(p.sensorType);
    final (trendIcon, trendColor, trendLabel) = _trendInfo(p.trend, sevLevel);
    final anomalyScore = p.anomalyScore.clamp(0.0, 1.0);
    final anomalyColor = _anomalyColor(anomalyScore);
    final anomalyPct = '${(anomalyScore * 100).toStringAsFixed(0)}%';

    return Container(
      decoration: BoxDecoration(
        color: ZeninColors.bgCard,
        border: Border.all(color: ZeninColors.borderSub, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECCIÓN A — Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: sensorColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(sensorIcon, color: sensorColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.sensorName.isNotEmpty ? p.sensorName : p.sensorType,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZeninColors.textSub,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.deviceName.isNotEmpty ? p.deviceName : '—',
                      style: const TextStyle(
                        fontSize: 11,
                        color: ZeninColors.textFaint,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // SECCIÓN B — Valor principal + sparkline
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor esperado · ${p.horizonMinutes} min'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: ZeninColors.textFaint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: p.predictedValue,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: ZeninColors.textPrimary,
                            ),
                          ),
                          if (p.unit.isNotEmpty)
                            TextSpan(
                              text: ' ${p.unit}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: ZeninColors.textDim,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(trendIcon, color: trendColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          trendLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MiniSparklineWidget(
                values: const [], // backend no envía serie en este modelo
                lineColor: trendColor,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // SECCIÓN C — Barra de anomalía
          Row(
            children: [
              const SizedBox(
                width: 56,
                child: Text(
                  'Anomalía',
                  style: TextStyle(
                    fontSize: 10,
                    color: ZeninColors.textFaint,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    height: 3,
                    color: ZeninColors.borderSub,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: anomalyScore,
                      child: Container(
                        decoration: BoxDecoration(
                          color: anomalyColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                anomalyPct,
                style: const TextStyle(
                  fontSize: 10,
                  color: ZeninColors.textFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // SECCIÓN D — Meta row
          const Divider(height: 1, color: ZeninColors.borderSub),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MetaChip(label: 'Confianza', value: '—'),
              const SizedBox(width: 16),
              _MetaChip(
                label: 'Último real',
                value: p.unit.isNotEmpty ? '— ${p.unit}' : '—',
              ),
              const SizedBox(width: 16),
              _MetaChip(label: 'Desv. estándar', value: '—'),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'en ${p.horizonMinutes} min',
                    style: const TextStyle(
                      fontSize: 10,
                      color: ZeninColors.textFaint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDateTime(p.targetTimestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: ZeninColors.textDim,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // SECCIÓN E — Acción
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onViewHistory,
              icon: const Icon(Icons.show_chart, size: 14),
              label: const Text(
                'Ver historial',
                style: TextStyle(fontSize: 11),
              ),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.pressed)) {
                      return ZeninColors.green;
                    }
                    return ZeninColors.textDim;
                  },
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                ),
                minimumSize: WidgetStateProperty.all(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: ZeninColors.textFaint,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: ZeninColors.textMuted,
          ),
        ),
      ],
    );
  }
}
