import 'package:flutter/material.dart';

import '../../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Widget to display configured thresholds for a sensor
class ThresholdSectionWidget extends StatelessWidget {
  const ThresholdSectionWidget({
    super.key,
    required this.thresholds,
    required this.unit,
  });

  final CanonicalThresholdsViewModel thresholds;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final hasWarning = thresholds.warning.min != null || thresholds.warning.max != null;
    final hasAlert = thresholds.alert.min != null || thresholds.alert.max != null;

    if (!hasWarning && !hasAlert) {
      return _emptyThresholds();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: 10),
          if (hasWarning)
            _buildThresholdRow(
              label: 'WARNING',
              min: thresholds.warning.min,
              max: thresholds.warning.max,
              unit: unit,
              color: DesignColors.amber,
            ),
          if (hasWarning && hasAlert) SizedBox(height: 6),
          if (hasAlert)
            _buildThresholdRow(
              label: 'ALERT',
              min: thresholds.alert.min,
              max: thresholds.alert.max,
              unit: unit,
              color: DesignColors.red,
            ),
        ],
      ),
    );
  }

  Widget _emptyThresholds() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[400], size: 18),
          SizedBox(width: 8),
          Text(
            'Sin umbrales configurados',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Icon(Icons.tune, color: Colors.blueGrey, size: 16),
        SizedBox(width: 6),
        Text(
          'Umbrales configurados',
          style: TextStyle(
            color: Colors.blueGrey[200],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildThresholdRow({
    required String label,
    required double? min,
    required double? max,
    required String unit,
    required Color color,
  }) {
    final minStr = min != null ? '${min.toStringAsFixed(2)} $unit' : '-';
    final maxStr = max != null ? '${max.toStringAsFixed(2)} $unit' : '-';

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Min: $minStr  •  Max: $maxStr',
            style: const TextStyle(
              color: DesignColors.textPrimary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
