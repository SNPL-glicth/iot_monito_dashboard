import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../../../../core/time/network_clock.dart';
import '../../../../alerts/presentation/pages/alerts_hub_page.dart';
import '../../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../monitoring/presentation/pages/sensor_month_picker_page.dart';
import '../../../../monitoring/presentation/pages/sensor_readings_page.dart';
import '../../../../monitoring/presentation/pages/sensor_week_readings_page.dart';
import '../sensor_thresholds_page.dart';
import 'sensor_delete_dialog.dart';
import 'sensor_edit_dialog.dart';
import '../../../../../core/theme/design_colors.dart';

/// Actions for sensor detail page (navigation, dialogs, etc.)
class SensorDetailActions {
  SensorDetailActions({
    required this.context,
    required this.role,
    required this.row,
    required this.monitoringRepo,
    required this.onRefresh,
  });

  final BuildContext context;
  final UserRole role;
  final DeviceWithSensorViewModel row;
  final dynamic monitoringRepo;
  final VoidCallback onRefresh;

  void handleSensorAction(String action) {
    switch (action) {
      case 'edit_sensor':
        showEditSensorDialog();
        break;
      case 'edit_thresholds':
        navigateToThresholds();
        break;
      case 'delete':
        showDeleteSensorDialog();
        break;
    }
  }

  Future<void> showEditSensorDialog() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => SensorEditDialog(row: row),
    );

    if (ok != true || !context.mounted) return;

    try {
      await monitoringRepo.updateSensor(row.sensorId!, name: row.sensorName ?? '');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sensor actualizado'), backgroundColor: Colors.green),
      );
      onRefresh();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: DesignColors.red),
      );
    }
  }

  Future<void> showDeleteSensorDialog() async {
    if (!row.canDelete) {
      showDialog(context: context, builder: (_) => const SensorCannotDeleteDialog());
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => SensorDeleteDialog(row: row),
    );

    if (ok != true || !context.mounted) return;

    try {
      final message = await monitoringRepo.deleteSensor(row.sensorId!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop('deleted');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: DesignColors.red),
      );
    }
  }

  void navigateToThresholds() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SensorThresholdsPage(
          role: role,
          sensorId: row.sensorId!,
          sensorName: row.sensorName?.trim().isEmpty ?? true ? 'Sensor' : row.sensorName!.trim(),
          sensorType: row.sensorType?.trim().isEmpty ?? true ? '-' : row.sensorType!.trim(),
          unit: row.unit?.trim() ?? '',
        ),
      ),
    );
  }

  void navigateToAlertsHub() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AlertsHubPage(role: role)),
    );
  }

  Future<void> openReadingsDay(String sensorName, String unit) async {
    final now = await NetworkClock.nowBogota();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SensorReadingsPage(
          role: role,
          sensorId: row.sensorId!,
          sensorNameHint: sensorName,
          unitHint: unit,
          filterLabel: 'Hoy',
          filterRange: DateTimeRange(start: DateTime(now.year, now.month, now.day), end: DateTime(now.year, now.month, now.day).add(const Duration(days: 1))),
          limit: 5000,
        ),
      ),
    );
  }

  void openReadingsWeek(String sensorName, String unit) {
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SensorWeekReadingsPage(
          role: role,
          sensorId: row.sensorId!,
          sensorNameHint: sensorName,
          unitHint: unit,
          limit: 5000,
        ),
      ),
    );
  }

  Future<void> openMonthPicker(String sensorName, String unit) async {
    final now = await NetworkClock.nowBogota();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SensorMonthPickerPage(
          role: role,
          sensorId: row.sensorId!,
          nowBogota: now,
          sensorNameHint: sensorName,
          unitHint: unit,
        ),
      ),
    );
  }
}
