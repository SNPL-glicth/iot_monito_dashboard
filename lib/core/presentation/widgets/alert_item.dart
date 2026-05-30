import 'package:flutter/material.dart';
import '../../theme/design_colors.dart';
import '../../theme/design_spacing.dart';
import '../../theme/design_text_styles.dart';

enum AlertSeverity { critical, warning, info }

class AlertItem extends StatelessWidget {
  const AlertItem({
    super.key,
    required this.message,
    required this.timestamp,
    required this.severity,
    this.deviceName,
  });

  final String message;
  final String timestamp;
  final AlertSeverity severity;
  final String? deviceName;

  Color get _borderColor {
    switch (severity) {
      case AlertSeverity.critical:
        return DesignColors.red;
      case AlertSeverity.warning:
        return DesignColors.amber;
      case AlertSeverity.info:
        return DesignColors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      decoration: BoxDecoration(
        color: DesignColors.surface2,
        border: Border(left: BorderSide(color: _borderColor, width: 3)),
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (deviceName != null)
            Container(
              margin: EdgeInsets.only(bottom: DesignSpacing.xs),
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: DesignColors.surfaceHover,
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Text(
                deviceName!.toUpperCase(),
                style: DesignTextStyles.badgeText(),
              ),
            ),
          Text(message, style: DesignTextStyles.cardTitle),
          SizedBox(height: DesignSpacing.xs),
          Text(timestamp, style: DesignTextStyles.timestamp),
        ],
      ),
    );
  }
}
