import 'package:flutter/material.dart';

import '../../../../../core/theme/zenin_colors.dart';

/// Barra de resumen con 4 celdas: Total, Normal, Advertencia, Crítico.
class SummaryBarWidget extends StatelessWidget {
  const SummaryBarWidget({
    super.key,
    required this.total,
    required this.normalCount,
    required this.warningCount,
    required this.criticalCount,
  });

  final int total;
  final int normalCount;
  final int warningCount;
  final int criticalCount;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: ZeninColors.border, width: 1),
            bottom: BorderSide(color: ZeninColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            _SummaryCell(
              label: 'Total sensores',
              value: total,
              color: ZeninColors.textPrimary,
            ),
            const VerticalDivider(width: 1, thickness: 1, color: ZeninColors.border),
            _SummaryCell(
              label: 'Normal',
              value: normalCount,
              color: ZeninColors.green,
            ),
            const VerticalDivider(width: 1, thickness: 1, color: ZeninColors.border),
            _SummaryCell(
              label: 'Advertencia',
              value: warningCount,
              color: ZeninColors.amber,
            ),
            const VerticalDivider(width: 1, thickness: 1, color: ZeninColors.border),
            _SummaryCell(
              label: 'Crítico',
              value: criticalCount,
              color: ZeninColors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ZeninColors.textFaint,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
