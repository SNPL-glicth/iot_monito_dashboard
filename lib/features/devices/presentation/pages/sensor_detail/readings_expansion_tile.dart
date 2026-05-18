import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Widget for readings expansion tile with period selection buttons
class ReadingsExpansionTile extends StatelessWidget {
  const ReadingsExpansionTile({
    super.key,
    required this.onDay,
    required this.onWeek,
    required this.onMonth,
  });

  final VoidCallback onDay;
  final VoidCallback onWeek;
  final VoidCallback onMonth;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      title: const Text('Lecturas (ver por período)', style: DashboardTextStyles.deviceTitle),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onDay,
                icon: const Icon(Icons.today_outlined, size: 18),
                label: const Text('Día'),
              ),
              OutlinedButton.icon(
                onPressed: onWeek,
                icon: const Icon(Icons.date_range_outlined, size: 18),
                label: const Text('Semana'),
              ),
              OutlinedButton.icon(
                onPressed: onMonth,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('Mes'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
