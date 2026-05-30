import 'package:flutter/material.dart';

import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';
import '../crm_dashboard_helpers.dart';
import '../../../data/models/crm_dashboard_models.dart';

/// Header de bienvenida con saludo dinámico según hora del día.
class CrmWelcomeHeader extends StatelessWidget {
  const CrmWelcomeHeader({
    super.key,
    required this.data,
  });

  final CrmDashboardResponse data;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    late final String greeting;
    late final IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Buenos días';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
      greetingIcon = Icons.wb_twilight;
    } else {
      greeting = 'Buenas noches';
      greetingIcon = Icons.nights_stay_outlined;
    }

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border.all(color: DesignColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: DesignColors.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: Icon(greetingIcon, color: DesignColors.cyan, size: 28),
          ),
          SizedBox(width: DesignSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, Administrador',
                  style: DesignTextStyles.screenTitle,
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'Período: ${CrmDashboardHelpers.formatDateTime(data.from)} → ${CrmDashboardHelpers.formatDateTime(data.to)}',
                  style: DesignTextStyles.bodyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
