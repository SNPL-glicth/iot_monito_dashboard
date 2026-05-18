import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
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
      padding: const EdgeInsets.all(20),
      decoration: ModernCardDecoration.elevated(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: DashboardColors.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(greetingIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, Administrador',
                  style: DashboardTextStyles.sectionHeader,
                ),
                const SizedBox(height: 4),
                Text(
                  'Período: ${CrmDashboardHelpers.formatDateTime(data.from)} → ${CrmDashboardHelpers.formatDateTime(data.to)}',
                  style: DashboardTextStyles.sensorMeta,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
