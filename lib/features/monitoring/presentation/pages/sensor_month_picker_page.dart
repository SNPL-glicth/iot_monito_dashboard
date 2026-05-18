import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import 'sensor_readings_page.dart';

class SensorMonthPickerPage extends StatelessWidget {
  const SensorMonthPickerPage({
    super.key,
    required this.role,
    required this.sensorId,
    required this.nowBogota,
    this.sensorNameHint,
    this.unitHint,
  });

  final UserRole role;
  final String sensorId;
  final DateTime nowBogota;
  final String? sensorNameHint;
  final String? unitHint;

  static const List<String> _monthsEs = <String>[
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final year = nowBogota.year;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes ($year)'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final label = _monthsEs[index];

          final start = DateTime(year, month, 1);
          final end = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);

          return Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.white70),
              title: Text(label),
              subtitle: Text('$label $year'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SensorReadingsPage(
                      role: role,
                      sensorId: sensorId,
                      sensorNameHint: sensorNameHint,
                      unitHint: unitHint,
                      filterLabel: '$label $year',
                      filterRange: DateTimeRange(start: start, end: end),
                      limit: 5000,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
