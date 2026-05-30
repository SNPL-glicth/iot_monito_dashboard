import 'package:flutter/material.dart';
import '../../../data/models/reading/raw_reading_models.dart';
import 'raw_diagnosis_stats_header.dart';
import 'raw_readings_list.dart';
import 'raw_sensor_chart.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


class RawDiagnosisSuccessBody extends StatelessWidget {
  const RawDiagnosisSuccessBody({
    super.key,
    required this.readings,
    required this.unit,
    this.lastFetchedAt,
    this.isLoading = false,
    required this.scrollController,
  });

  final List<RawReadingItem> readings;
  final String unit;
  final DateTime? lastFetchedAt;
  final bool isLoading;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RawDiagnosisStatsHeader(
          readingCount: readings.length,
          lastFetchedAt: lastFetchedAt,
          isLoading: isLoading,
        ),
        Expanded(
          flex: 2,
          child: Card(
            margin: EdgeInsets.all(DesignSpacing.sm),
            color: DesignColors.surface,
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: RawSensorChart(readings: readings, unit: unit),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
            color: DesignColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(DesignSpacing.md),
                  child: Text('Historial de lecturas', style: DesignTextStyles.cardTitle),
                ),
                Expanded(
                  child: RawReadingsList(
                    readings: readings,
                    unit: unit,
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
