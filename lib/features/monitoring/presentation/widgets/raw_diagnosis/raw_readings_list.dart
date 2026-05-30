import 'package:flutter/material.dart';

import '../../../data/models/reading/raw_reading_models.dart';
import '../../../../../core/theme/design_colors.dart';

/// Lista scrollable de lecturas crudas de sensor.
class RawReadingsList extends StatelessWidget {
  const RawReadingsList({
    super.key,
    required this.readings,
    required this.unit,
    required this.scrollController,
  });

  final List<RawReadingItem> readings;
  final String unit;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: readings.length,
      itemBuilder: (context, index) {
        final r = readings[index];
        return ListTile(
          dense: true,
          leading: Text(
            r.value.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          title: Text(
            unit,
            style: TextStyle(color: DesignColors.textPrimary, fontSize: 12),
          ),
          trailing: Text(
            r.timestampFormatted,
            style: TextStyle(color: DesignColors.textSecondary, fontSize: 11),
          ),
        );
      },
    );
  }
}
