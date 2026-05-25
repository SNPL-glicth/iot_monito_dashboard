import 'package:flutter/material.dart';

import '../../styles/dashboard_styles.dart';

class RawDiagnosisEmptyState extends StatelessWidget {
  const RawDiagnosisEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Sin lecturas', style: DashboardTextStyles.deviceTitle),
          const SizedBox(height: 8),
          Text('No hay datos para este sensor aún.', style: DashboardTextStyles.sensorMeta),
        ],
      ),
    );
  }
}
