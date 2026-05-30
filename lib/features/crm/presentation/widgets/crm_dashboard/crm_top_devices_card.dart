import 'package:flutter/material.dart';
import '../../../data/models/crm_dashboard_models.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Card de dispositivos prioritarios por cantidad de alertas activas.
class CrmTopDevicesCard extends StatelessWidget {
  const CrmTopDevicesCard({
    super.key,
    required this.topDevices,
  });

  final List<CrmTopDeviceByActiveAlerts> topDevices;

  @override
  Widget build(BuildContext context) {
    final items = topDevices.take(5).toList();

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: DesignColors.amber, size: 20),
              SizedBox(width: DesignSpacing.sm),
              Text('Dispositivos Prioritarios', style: DesignTextStyles.cardTitle),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final d = entry.value;
            final isFirst = idx == 0;

            return Padding(
              padding: EdgeInsets.only(bottom: DesignSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? DesignColors.amber.withValues(alpha: 0.2)
                          : DesignColors.border,
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: isFirst ? DesignColors.amber : DesignColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: Text(
                      d.deviceName,
                      style: DesignTextStyles.bodyText,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
                    decoration: BoxDecoration(
                      color: DesignColors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                    ),
                    child: Text(
                      '${d.activeAlerts} alertas',
                      style: DesignTextStyles.badgeText(color: DesignColors.red),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
