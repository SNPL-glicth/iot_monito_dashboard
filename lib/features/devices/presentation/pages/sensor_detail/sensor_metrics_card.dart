import 'package:flutter/material.dart';
import '../../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Widget to display sensor metrics (current value, state, ML events, etc.)
class SensorMetricsCard extends StatelessWidget {
  const SensorMetricsCard({
    super.key,
    required this.dashboard,
    required this.unit,
    required this.isSensorActive,
    required this.refreshing,
  });

  final SensorDashboardViewModel dashboard;
  final String unit;
  final bool isSensorActive;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final m = dashboard.metrics;
    final currentValue = (m.currentValue == null) 
        ? '-' 
        : m.currentValue!.toStringAsFixed(2);
    final currentTs = _formatDateTime(m.currentTimestamp);
    final state = m.state;
    final stColor = _tradingStateColor(state);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(stColor, isSensorActive),
            SizedBox(height: DesignSpacing.sm),
            _currentValue(currentValue, unit),
            SizedBox(height: DesignSpacing.sm),
            _kv('Lectura', currentTs),
            SizedBox(height: DesignSpacing.sm),
            _stateBadge(state, stColor),
            if (m.isWarmingUp) ...[
              SizedBox(height: DesignSpacing.sm),
              _warmUpIndicator(m),
            ],
            if (dashboard.mlEvent != null) ...[
              SizedBox(height: DesignSpacing.sm),
              _mlEventCard(dashboard.mlEvent!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(Color stColor, bool isSensorActive) {
    return Row(
      children: [
        const Icon(Icons.show_chart, color: Color(0xFF00E676)),
        SizedBox(width: DesignSpacing.sm),
        Expanded(
          child: Text(
            'Estado y última lectura',
            style: DesignTextStyles.cardTitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: DesignSpacing.sm),
        if (refreshing)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        SizedBox(width: DesignSpacing.sm),
        Chip(
          label: Text(
            isSensorActive ? 'ACTIVO' : 'INACTIVO',
            style: isSensorActive
                ? DesignTextStyles.timestamp.copyWith(color: DesignColors.green)
                : DesignTextStyles.timestamp.copyWith(color: DesignColors.red),
          ),
          backgroundColor: isSensorActive
              ? Colors.green.withValues(alpha: 0.18)
              : Colors.red.withValues(alpha: 0.18),
          side: BorderSide(
            color: isSensorActive
                ? DesignTextStyles.timestamp.copyWith(color: DesignColors.green).color!
                : DesignTextStyles.timestamp.copyWith(color: DesignColors.red).color!,
          ),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _currentValue(String value, String unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (unit.isNotEmpty) ...[
          SizedBox(width: DesignSpacing.sm),
          Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              unit,
              style: TextStyle(
                color: DesignColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _stateBadge(String state, Color stColor) {
    return Row(
      children: [
        Text('Estado actual', style: DesignTextStyles.timestamp),
        SizedBox(width: DesignSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: stColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(color: stColor.withValues(alpha: 0.35)),
          ),
          child: Text(
            state.toUpperCase(),
            style: TextStyle(
              color: stColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _warmUpIndicator(TelemetryMetricsViewModel m) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sensor en calentamiento',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'Acumulando lecturas base (${m.operationalState.validReadingsCount}/${m.operationalState.minReadingsForNormal}). '
                  'No se generarán alertas hasta completar.',
                  style: TextStyle(
                    color: Colors.blueAccent.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mlEventCard(MlEventViewModel mlEvent) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.purpleAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mlEvent.title,
            style: const TextStyle(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 6),
          Text(
            (mlEvent.message ?? '').trim().isEmpty
                ? 'Evento ML registrado.'
                : mlEvent.message!.trim(),
            style: DesignTextStyles.bodyText,
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(k, style: DesignTextStyles.timestamp),
        ),
        SizedBox(width: DesignSpacing.sm),
        Expanded(
          child: Text(v, style: DesignTextStyles.bodyText),
        ),
      ],
    );
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      final now = DateTime.now();
      final formatter = now.year == iso.year && now.month == iso.month && now.day == iso.day
          ? 'HH:mm'
          : 'dd/MM/yyyy HH:mm';
      return formatter == 'HH:mm'
          ? 'Hoy ${iso.hour.toString().padLeft(2, '0')}:${iso.minute.toString().padLeft(2, '0')}'
          : '${iso.day.toString().padLeft(2, '0')}/${iso.month.toString().padLeft(2, '0')} ${iso.hour.toString().padLeft(2, '0')}:${iso.minute.toString().padLeft(2, '0')}';
    }
    return raw;
  }

  Color _tradingStateColor(String raw) {
    switch (raw.toUpperCase()) {
      case 'ALERT':
        return DesignColors.red;
      case 'WARNING':
        return DesignColors.amber;
      default:
        return Colors.tealAccent;
    }
  }
}
