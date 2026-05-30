import 'package:flutter/material.dart';
import '../../../../../features/monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Icon(Icons.sensors_rounded, color: DesignColors.amber, size: 22),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eliminar lecturas de un sensor', style: DesignTextStyles.cardTitle),
                    SizedBox(height: 2),
                    Text('Selecciona el sensor para borrar solo sus lecturas.', style: DesignTextStyles.bodyText),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),
          FutureBuilder<List<DeviceWithSensorViewModel>>(
            future: sensorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error al cargar sensores: ${snapshot.error}', style: DesignTextStyles.bodyText);
              }

              final rows = (snapshot.data ?? const <DeviceWithSensorViewModel>[])
                  .where((r) => r.sensorId != null)
                  .toList();
              if (rows.isEmpty) {
                return Text('No hay sensores disponibles para seleccionar.', style: DesignTextStyles.bodyText);
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
                dropdownColor: DesignColors.surface2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Seleccionar sensor',
                  labelStyle: TextStyle(color: DesignColors.textPrimary),
                  prefixIcon: Icon(Icons.sensors_outlined, color: DesignColors.textSecondary, size: 20),
                  filled: true,
                  fillColor: DesignColors.surface2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide(color: DesignColors.border)),
                ),
                items: rows.map((r) => DropdownMenuItem<String>(
                  value: r.sensorId,
                  child: Text(buildLabel(r), overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: isBusy ? null : (value) => onSensorChanged(value),
              );
            },
          ),
          SizedBox(height: DesignSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.amber,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)),
              ),
              onPressed: isBusy ? null : onDelete,
              child: isBusy
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
