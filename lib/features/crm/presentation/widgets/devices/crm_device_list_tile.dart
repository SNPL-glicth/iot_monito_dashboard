import 'package:flutter/material.dart';
import '../../../data/models/crm_devices_models.dart';
import '../../pages/crm_device_details_page.dart';
import '../../pages/crm_device_type_page.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Tile de dispositivo en la lista CRM.
class CrmDeviceListTile extends StatelessWidget {
  const CrmDeviceListTile({
    super.key,
    required this.device,
    required this.role,
    required this.formatDateTime,
  });

  final CrmDeviceSummary device;
  final dynamic role;
  final String Function(String?) formatDateTime;

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.greenAccent;
      case 'offline':
        return DesignColors.red;
      case 'maintenance':
        return DesignColors.amber;
      case 'error':
        return Colors.red;
      default:
        return DesignColors.textSecondary;
    }
  }

  static String typeLabel(String raw) {
    final t = raw.trim().toLowerCase();
    if (t.contains('electric') || t.contains('eléctr') || t.contains('electr')) {
      return 'Medidor eléctrico';
    }
    if (t.contains('frigo')) {
      return 'Frigorífico';
    }
    if (t.contains('ambient') || t.contains('clima')) {
      return 'Ambiental';
    }
    return raw.trim().isEmpty ? '—' : raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(device.status);
    final deviceType = typeLabel(device.deviceType);

    return Card(
      child: ListTile(
        leading: Icon(Icons.memory, color: color),
        title: Text(deviceType, style: DesignTextStyles.cardTitle),
        subtitle: Text(
          'Nombre: ${device.deviceName} · Estado: ${device.status} · Sensores: ${device.sensorCount} · Alertas activas: ${device.activeAlerts}\n'
          'Última conexión: ${formatDateTime(device.lastConnection)}',
          style: DesignTextStyles.bodyText,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CrmDeviceTypePage(
                role: role,
                deviceType: device.deviceType,
              ),
            ),
          );
        },
        onLongPress: () {
          final id = int.tryParse(device.deviceId);
          if (id == null) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CrmDeviceDetailsPage(
                role: role,
                deviceId: id,
                deviceNameHint: device.deviceName,
              ),
            ),
          );
        },
      ),
    );
  }
}
