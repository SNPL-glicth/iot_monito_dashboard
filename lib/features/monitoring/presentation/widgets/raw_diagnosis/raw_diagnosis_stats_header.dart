import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../styles/dashboard_styles.dart';

class RawDiagnosisStatsHeader extends StatelessWidget {
  const RawDiagnosisStatsHeader({
    super.key,
    required this.readingCount,
    this.lastFetchedAt,
    this.isLoading = false,
  });

  final int readingCount;
  final DateTime? lastFetchedAt;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: DashboardColors.cardBackground,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$readingCount lecturas',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (lastFetchedAt != null)
                  Text(
                    'Actualizado: ${DateFormat('HH:mm:ss').format(lastFetchedAt!)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}
