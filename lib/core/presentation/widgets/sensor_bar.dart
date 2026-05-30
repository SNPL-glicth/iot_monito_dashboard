import 'package:flutter/material.dart';
import '../../theme/design_colors.dart';
import '../../theme/design_spacing.dart';
import '../../theme/design_text_styles.dart';
import 'status_badge.dart';

class SensorBar extends StatelessWidget {
  const SensorBar({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.unit,
    this.state = MachineState.idle,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String? unit;
  final MachineState state;

  Color get _barColor {
    switch (state) {
      case MachineState.running:
        return DesignColors.green;
      case MachineState.starting:
        return DesignColors.cyan;
      case MachineState.degraded:
        return DesignColors.amber;
      case MachineState.fault:
        return DesignColors.red;
      case MachineState.idle:
        return DesignColors.textDim;
    }
  }

  double get _progress {
    if (max <= min) return 0;
    final p = (value - min) / (max - min);
    return p.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: DesignTextStyles.bodyText,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: DesignColors.surface2,
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                minHeight: 6,
              ),
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          SizedBox(
            width: 60,
            child: Text(
              '${value.toStringAsFixed(1)}${unit ?? ''}',
              style: DesignTextStyles.metricValue,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _barColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
