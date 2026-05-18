import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_helpers.dart';

/// Footer widget showing diagnostic timestamp
class FooterWidget extends StatelessWidget {
  const FooterWidget({
    super.key,
    required this.timestamp,
  });

  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Diagnóstico generado: ${IntelligenceHealthHelpers.formatDateTime(timestamp)}',
        style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 11),
      ),
    );
  }
}
