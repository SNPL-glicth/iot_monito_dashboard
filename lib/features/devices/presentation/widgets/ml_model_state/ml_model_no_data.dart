import 'package:flutter/material.dart';

import '../../../../../core/theme/chart_style.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Estado vacío del widget de estado ML.
class MlModelNoData extends StatelessWidget {
  const MlModelNoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: ChartStyle.backgroundColor,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: ChartStyle.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.psychology_outlined,
            color: Colors.white.withValues(alpha: 0.3),
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'ML sin datos',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
