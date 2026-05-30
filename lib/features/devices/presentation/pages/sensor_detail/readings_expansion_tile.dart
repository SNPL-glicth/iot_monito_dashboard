import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
      tilePadding: EdgeInsets.symmetric(horizontal: 12),
      title: Text('Lecturas (ver por período)', style: DesignTextStyles.cardTitle),
      children: [
        Padding(
          padding: EdgeInsets.all(DesignSpacing.md),
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
