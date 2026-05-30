import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../widgets/clean_readings/delete_all_readings_card.dart';
import '../widgets/clean_readings/delete_by_sensor_card.dart';
import '../widgets/clean_readings/confirm_delete_dialog.dart';
import '../widgets/clean_readings/result_message_banner.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';


/// Pantalla de utilería para limpiar lecturas de sensores.
/// Solo para administradores.
class DevicesCleanReadingsPage extends StatefulWidget {
  const DevicesCleanReadingsPage({super.key});

  @override
  State<DevicesCleanReadingsPage> createState() => _DevicesCleanReadingsPageState();
}

class _DevicesCleanReadingsPageState extends State<DevicesCleanReadingsPage> {
  late final MonitoringRepository _monitoringRepository;
  late Future<List<DeviceWithSensorViewModel>> _sensorsFuture;

  bool _isBusy = false;
  String? _message;
  String? _selectedSensorId;

  @override
  void initState() {
    super.initState();
    _monitoringRepository = MonitoringRepository();
    _sensorsFuture = _monitoringRepository.fetchDevicesWithSensors();
  }

  Future<void> _deleteAllReadings() async {
    setState(() {
      _isBusy = true;
      _message = null;
    });

    try {
      final client = ApiClient();
      // Backend: DELETE /monitoring/dev-tools/sensor-readings/all
      await client.delete('/monitoring/dev-tools/sensor-readings/all');
      setState(() {
        _message = 'Se eliminaron todas las lecturas de sensores.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error al eliminar lecturas: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _confirmAndDeleteBySensor() async {
    final sensorId = _selectedSensorId;
    if (sensorId == null || sensorId.trim().isEmpty) {
      setState(() {
        _message = 'Selecciona un sensor válido.';
      });
      return;
    }

    // Resolver etiqueta del sensor para mostrar en el diálogo
    String sensorLabel = sensorId;
    try {
      final sensors = await _sensorsFuture;
      final match = sensors.firstWhere(
        (s) => s.sensorId == sensorId,
        orElse: () => throw Exception('not found'),
      );
      final sensorName = (match.sensorName ?? match.sensorType ?? '-').trim();
      final unit = (match.unit ?? '').trim();
      final unitSuffix = unit.isEmpty ? '' : ' · $unit';
      sensorLabel = '${match.deviceName} · $sensorName$unitSuffix';
    } catch (_) {
      // Fallback al sensorId
    }

    if (!mounted) return;

    final confirmed = await showConfirmDeleteBySensorDialog(
      context,
      sensorLabel: sensorLabel,
    );
    if (confirmed) await _deleteBySensor(sensorLabel: sensorLabel);
  }

  Future<void> _deleteBySensor({String? sensorLabel}) async {
    final sensorId = _selectedSensorId;
    if (sensorId == null || sensorId.trim().isEmpty) {
      setState(() {
        _message = 'Selecciona un sensor válido.';
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _message = null;
    });

    try {
      final client = ApiClient();
      // Backend: DELETE /monitoring/dev-tools/sensor-readings/sensor/:sensorId
      await client.delete('/monitoring/dev-tools/sensor-readings/sensor/$sensorId');
      setState(() {
        _message = 'Se eliminaron las lecturas del sensor ${sensorLabel ?? sensorId}.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error al eliminar lecturas del sensor ${sensorLabel ?? sensorId}: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Limpiar lecturas de sensores'),
      ),
      body: AbsorbPointer(
        absorbing: _isBusy,
        child: ListView(
          padding: EdgeInsets.all(DesignSpacing.lg),
          children: [
            // Header con advertencia
            Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: DesignColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(color: DesignColors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: DesignColors.amber, size: 24),
                  SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: Text(
                      'Esta herramienta permite eliminar lecturas históricas de sensores para tareas de mantenimiento. Úsala con cuidado.',
                      style: TextStyle(color: DesignColors.amber, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            
            DeleteAllReadingsCard(
              isBusy: _isBusy,
              onConfirm: () async {
                final confirmed = await showConfirmDeleteAllDialog(context);
                if (confirmed) await _deleteAllReadings();
              },
            ),
            SizedBox(height: DesignSpacing.lg),
            
            DeleteBySensorCard(
              sensorsFuture: _sensorsFuture,
              selectedSensorId: _selectedSensorId,
              isBusy: _isBusy,
              onSensorChanged: (value) => setState(() => _selectedSensorId = value),
              onDelete: _confirmAndDeleteBySensor,
            ),
            
            if (_message != null) ...[
              SizedBox(height: DesignSpacing.lg),
              ResultMessageBanner(message: _message!),
            ],
          ],
        ),
      ),
    );
  }

}
