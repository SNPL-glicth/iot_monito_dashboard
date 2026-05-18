import 'package:flutter/material.dart';

import '../../../../../features/monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Card con dropdown para eliminar lecturas de un sensor específico.
class DeleteBySensorCard extends StatelessWidget {
  const DeleteBySensorCard({
    super.key,
    required this.sensorsFuture,
    required this.selectedSensorId,
    required this.isBusy,
    required this.onSensorChanged,
    required this.onDelete,
  });

  final Future<List<DeviceWithSensorViewModel>> sensorsFuture;
  final String? selectedSensorId;
  final bool isBusy;
  final ValueChanged<String?> onSensorChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DashboardColors.orangeAccent15,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.sensors_rounded, color: DashboardColors.warning, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eliminar lecturas de un sensor', style: DashboardTextStyles.deviceTitle),
                    SizedBox(height: 2),
                    Text('Selecciona el sensor para borrar solo sus lecturas.', style: DashboardTextStyles.sensorMeta),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<DeviceWithSensorViewModel>>(
            future: sensorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error al cargar sensores: ${snapshot.error}', style: DashboardTextStyles.error);
              }

              final rows = (snapshot.data ?? const <DeviceWithSensorViewModel>[])
                  .where((r) => r.sensorId != null)
                  .toList();
              if (rows.isEmpty) {
                return const Text('No hay sensores disponibles para seleccionar.', style: DashboardTextStyles.sensorMeta);
              }

              rows.sort((a, b) {
                final da = a.deviceName.toLowerCase();
                final db = b.deviceName.toLowerCase();
                final sa = (a.sensorName ?? a.sensorType ?? '').toLowerCase();
                final sb = (b.sensorName ?? b.sensorType ?? '').toLowerCase();
                final cmp = da.compareTo(db);
                return cmp != 0 ? cmp : sa.compareTo(sb);
              });

              String buildLabel(DeviceWithSensorViewModel r) {
                final sensorLabel = (r.sensorName ?? r.sensorType ?? '-').trim();
                final unit = (r.unit ?? '').trim();
                final unitSuffix = unit.isEmpty ? '' : ' · $unit';
                return '${r.deviceName} · $sensorLabel$unitSuffix';
              }

              return DropdownButtonFormField<String>(
                initialValue: selectedSensorId,
                isExpanded: true,
                dropdownColor: DashboardColors.surfaceElevated,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Seleccionar sensor',
                  labelStyle: TextStyle(color: DashboardColors.white70),
                  prefixIcon: Icon(Icons.sensors_outlined, color: DashboardColors.white54, size: 20),
                  filled: true,
                  fillColor: DashboardColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: DashboardColors.white10)),
                ),
                items: rows.map((r) => DropdownMenuItem<String>(
                  value: r.sensorId,
                  child: Text(buildLabel(r), overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: isBusy ? null : (value) => onSensorChanged(value),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.warning,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isBusy ? null : onDelete,
              child: isBusy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Eliminar lecturas del sensor'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
