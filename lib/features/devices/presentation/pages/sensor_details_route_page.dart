import 'package:flutter/material.dart';

import '../../../../core/auth/current_user.dart';
import '../../../../core/auth/user_role.dart';
import '../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../../../monitoring/data/models/device_with_sensor_view_model.dart';
import 'sensor_detail_page.dart';

class SensorDetailsArgs {
  const SensorDetailsArgs({
    required this.sensorId,
    this.highlightTimestamp,
  });

  final String sensorId;
  
  /// Timestamp a resaltar en la gráfica (desde click en notificación)
  final DateTime? highlightTimestamp;
}

class SensorDetailsRoutePage extends StatelessWidget {
  const SensorDetailsRoutePage({
    super.key,
    required this.args,
  });

  final SensorDetailsArgs args;

  UserRole _mapRole(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'viewer':
      default:
        return UserRole.viewer;
    }
  }

  Future<({DeviceWithSensorViewModel row, LatestSensorReadingViewModel? latest})> _load(MonitoringRepository repo) async {
    final sensorId = args.sensorId;

    final devices = await repo.fetchDevicesWithSensors();
    final row = devices.firstWhere(
      (d) => (d.sensorId ?? '') == sensorId,
      orElse: () => throw Exception('Sensor no encontrado: $sensorId'),
    );

    LatestSensorReadingViewModel? latest;
    try {
      final latestAll = await repo.fetchLatestSensorReadings();
      for (final r in latestAll) {
        if (r.sensorId == sensorId) {
          latest = r;
          break;
        }
      }
    } catch (_) {
      // Si falla latest, igual abrimos detalle con la data mínima.
    }

    return (row: row, latest: latest);
  }

  @override
  Widget build(BuildContext context) {
    final role = _mapRole(CurrentUser.value?.role);

    final repo = MonitoringRepository();
    final future = _load(repo);

    return FutureBuilder<({DeviceWithSensorViewModel row, LatestSensorReadingViewModel? latest})>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalles de sensor')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error abriendo detalle: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        return SensorDetailPage(
          role: role,
          row: data.row,
          latest: data.latest,
          highlightTimestamp: args.highlightTimestamp,
        );
      },
    );
  }
}
