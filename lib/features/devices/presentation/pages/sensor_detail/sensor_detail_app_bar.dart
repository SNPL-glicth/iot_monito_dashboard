import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../../../monitoring/data/models/device_with_sensor_view_model.dart';
import 'sensor_utils.dart';

/// AppBar widget for sensor detail page
class SensorDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SensorDetailAppBar({
    super.key,
    required this.role,
    required this.row,
    required this.onActionSelected,
    required this.onAlertsPressed,
  });

  final UserRole role;
  final DeviceWithSensorViewModel row;
  final void Function(String) onActionSelected;
  final VoidCallback onAlertsPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final sensorName = row.sensorName?.trim().isEmpty ?? true ? '—' : row.sensorName!.trim();
    final sensorType = SensorUtils.sensorTypeLabel(row.sensorType);
    final accent = SensorUtils.sensorAccentColor(row.sensorType);

    return AppBar(
      title: Row(
        children: [
          Icon(SensorUtils.sensorIcon(row.sensorType), color: accent, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              sensorName == '—' ? (sensorType.trim().isEmpty ? 'Sensor' : sensorType) : sensorName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (role == UserRole.admin && row.sensorId != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: onActionSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit_sensor', child: Text('Editar sensor')),
              const PopupMenuItem(value: 'edit_thresholds', child: Text('Editar umbrales')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'delete', child: Text('Eliminar sensor')),
            ],
          ),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: onAlertsPressed,
        ),
      ],
    );
  }
}
