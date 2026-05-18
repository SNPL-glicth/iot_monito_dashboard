import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../widgets/clean_readings/delete_all_readings_card.dart';
import '../widgets/clean_readings/delete_by_sensor_card.dart';
import '../widgets/clean_readings/confirm_delete_dialog.dart';
import '../widgets/clean_readings/result_message_banner.dart';

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

  Future<void> _deleteBySensor() async {
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
        _message = 'Se eliminaron las lecturas del sensor $sensorId.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error al eliminar lecturas del sensor $sensorId: $e';
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
          padding: const EdgeInsets.all(20),
          children: [
            // Header con advertencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DashboardColors.orangeAccent15,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DashboardColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: DashboardColors.warning, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Esta herramienta permite eliminar lecturas históricas de sensores para tareas de mantenimiento. Úsala con cuidado.',
                      style: TextStyle(color: DashboardColors.warning, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            DeleteAllReadingsCard(
              isBusy: _isBusy,
              onConfirm: () async {
                final confirmed = await showConfirmDeleteAllDialog(context);
                if (confirmed) await _deleteAllReadings();
              },
            ),
            const SizedBox(height: 16),
            
            DeleteBySensorCard(
              sensorsFuture: _sensorsFuture,
              selectedSensorId: _selectedSensorId,
              isBusy: _isBusy,
              onSensorChanged: (value) => setState(() => _selectedSensorId = value),
              onDelete: _deleteBySensor,
            ),
            
            if (_message != null) ...[
              const SizedBox(height: 20),
              ResultMessageBanner(message: _message!),
            ],
          ],
        ),
      ),
    );
  }

}
