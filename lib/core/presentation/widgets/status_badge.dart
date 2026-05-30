import 'package:flutter/material.dart';
import '../../theme/design_colors.dart';
import '../../theme/design_spacing.dart';
import '../../theme/design_text_styles.dart';

enum MachineState { running, starting, degraded, fault, idle }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.state,
  });

  final String label;
  final MachineState state;

  Color get _color {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 0.5),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            label.toUpperCase(),
            style: DesignTextStyles.badgeText(color: _color),
          ),
        ],
      ),
    );
  }
}
