import 'package:flutter/material.dart';

import '../../../data/models/reading/raw_reading_models.dart';
import '../../styles/dashboard_styles.dart';
import 'raw_diagnosis_stats_header.dart';
import 'raw_readings_list.dart';
import 'raw_sensor_chart.dart';

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
            margin: const EdgeInsets.all(8),
            color: DashboardColors.cardBackground,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: RawSensorChart(readings: readings, unit: unit),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            color: DashboardColors.cardBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Historial de lecturas', style: DashboardTextStyles.deviceTitle),
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
