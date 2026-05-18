import 'package:flutter/material.dart';

import 'sensor_utils.dart';

/// Dialog to show details of a selected data point
class PointDetailsDialog extends StatelessWidget {
  const PointDetailsDialog({
    super.key,
    required this.point,
    required this.unit,
  });

  final dynamic point;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(point.state, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Valor: ${point.value.toStringAsFixed(2)} $unit'),
          Text('Hora: ${SensorUtils.formatDateTime(point.timestamp.toIso8601String())}'),
        ],
      ),
    );
  }
}
