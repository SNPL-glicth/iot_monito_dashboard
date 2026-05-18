import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import 'raw_readings_chart_view.dart';

/// Página de selección de sensor para lecturas crudas.
class RawSensorReadingsPage extends StatefulWidget {
  const RawSensorReadingsPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.sensors,
  });

  final String deviceId;
  final String deviceName;
  final List<({String id, String name, String? unit})> sensors;

  @override
  State<RawSensorReadingsPage> createState() => _RawSensorReadingsPageState();
}

class _RawSensorReadingsPageState extends State<RawSensorReadingsPage> {
  String? _selectedSensorId;
  String? _selectedSensorName;
  String? _selectedUnit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedSensorId == null
            ? 'Lecturas Crudas - ${widget.deviceName}'
            : _selectedSensorName ?? 'Sensor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedSensorId != null) {
              setState(() {
                _selectedSensorId = null;
                _selectedSensorName = null;
                _selectedUnit = null;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _selectedSensorId == null
          ? _buildSensorList()
          : RawReadingsChartView(
              sensorId: _selectedSensorId!,
              sensorName: _selectedSensorName ?? 'Sensor',
              unit: _selectedUnit,
            ),
    );
  }

  Widget _buildSensorList() {
    if (widget.sensors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sensors_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin sensores activos',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No hay sensores habilitados en este dispositivo',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.sensors.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sensors, color: Colors.tealAccent, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Sensores Activos',
                      style: DashboardTextStyles.sectionHeader,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona un sensor para ver sus lecturas crudas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        final sensor = widget.sensors[index - 1];
        final unitText = sensor.unit != null && sensor.unit!.isNotEmpty
            ? ' (${sensor.unit})'
            : '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.tealAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.show_chart,
                color: Colors.tealAccent,
                size: 22,
              ),
            ),
            title: Text(
              sensor.name.isEmpty ? 'Sensor ${sensor.id}' : sensor.name,
              style: DashboardTextStyles.sensorTitle,
            ),
            subtitle: Text(
              'ID: ${sensor.id}$unitText',
              style: DashboardTextStyles.sensorMeta,
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {
              setState(() {
                _selectedSensorId = sensor.id;
                _selectedSensorName = sensor.name.isEmpty ? 'Sensor ${sensor.id}' : sensor.name;
                _selectedUnit = sensor.unit;
              });
            },
          ),
        );
      },
    );
  }
}
