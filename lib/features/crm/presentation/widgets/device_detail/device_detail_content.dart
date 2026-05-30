import 'package:flutter/material.dart';
import '../../../../../core/auth/user_role.dart';
import '../../../data/models/crm_devices_models.dart';
import '../../pages/crm_device_alerts_page.dart';
import '../../pages/crm_device_history_page.dart';
import 'device_detail_helpers.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Contenido de la página de detalle de dispositivo CRM.
class DeviceDetailContent extends StatelessWidget {
  const DeviceDetailContent({
    super.key,
    required this.data,
    required this.role,
    required this.deviceId,
    required this.formatDateTime,
  });

  final CrmDeviceProfileFullResponse data;
  final UserRole role;
  final int deviceId;
  final String Function(String?) formatDateTime;

  @override
  Widget build(BuildContext context) {
    final s = data.summary;
    final statusColor = DeviceDetailHelpers.statusColor(s.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(icon: Icons.info_outline, title: 'Resumen', color: Colors.tealAccent),
        SizedBox(height: DesignSpacing.sm),
        Card(
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.memory, color: statusColor),
                    SizedBox(width: DesignSpacing.sm),
                    Expanded(
                      child: Text(
                        s.deviceName,
                        style: DesignTextStyles.cardTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Chip(
                      label: Text(s.status),
                      backgroundColor: Colors.white10,
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ],
                ),
                SizedBox(height: DesignSpacing.sm),
                Text('UUID: ${s.deviceUuid}', style: DesignTextStyles.bodyText),
                Text('Tipo: ${s.deviceType}', style: DesignTextStyles.bodyText),
                Text('Sensores: ${s.sensorCount}', style: DesignTextStyles.bodyText),
                Text('Alertas activas: ${s.activeAlerts}', style: DesignTextStyles.bodyText),
                Text('Última conexión: ${formatDateTime(s.lastConnection)}', style: DesignTextStyles.bodyText),
                Text('Última alerta: ${formatDateTime(s.lastAlertAt)}', style: DesignTextStyles.bodyText),
              ],
            ),
          ),
        ),
        SizedBox(height: DesignSpacing.lg),
        _sectionHeader(icon: Icons.query_stats_outlined, title: 'KPIs del dispositivo', color: DesignColors.amber),
        SizedBox(height: DesignSpacing.sm),
        Card(
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rango: ${formatDateTime(data.from)} → ${formatDateTime(data.to)} (bucket: ${data.bucket})',
                  style: DesignTextStyles.bodyText,
                ),
                SizedBox(height: DesignSpacing.sm),
                Text('Alertas 24h:', style: DesignTextStyles.cardTitle),
                SizedBox(height: 6),
                _chipsFromMap(data.kpisAlerts24h),
                SizedBox(height: DesignSpacing.md),
                Text('Alertas 7d:', style: DesignTextStyles.cardTitle),
                SizedBox(height: 6),
                _chipsFromMap(data.kpisAlerts7d),
              ],
            ),
          ),
        ),
        SizedBox(height: DesignSpacing.lg),
        _sectionHeader(icon: Icons.insights, title: 'Histórico y métricas', color: Colors.cyanAccent),
        SizedBox(height: DesignSpacing.sm),
        Card(
          child: ListTile(
            leading: const Icon(Icons.query_stats_outlined, color: Colors.cyanAccent),
            title: Text('Ver histórico + métricas', style: DesignTextStyles.cardTitle),
            subtitle: Text(
              'Sensores: ${data.sensors.length}\n'
              'Rango: ${formatDateTime(data.from)} → ${formatDateTime(data.to)} (bucket: ${data.bucket})',
              style: DesignTextStyles.bodyText,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CrmDeviceHistoryPage(
                    role: role,
                    deviceId: deviceId,
                    deviceNameHint: s.deviceName,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: DesignSpacing.lg),
        _sectionHeader(icon: Icons.warning_amber_rounded, title: 'Historial de alertas', color: DesignColors.red),
        SizedBox(height: DesignSpacing.sm),
        Card(
          child: ListTile(
            leading: Icon(Icons.history, color: DesignColors.red),
            title: Text('Ver historial de alertas', style: DesignTextStyles.cardTitle),
            subtitle: Text(
              'Alertas activas: ${s.activeAlerts}\n'
              'Última alerta: ${formatDateTime(s.lastAlertAt)}',
              style: DesignTextStyles.bodyText,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CrmDeviceAlertsPage(
                    role: role,
                    deviceId: deviceId,
                    deviceNameHint: s.deviceName,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader({required IconData icon, required String title, Color? color}) {
    final accent = color ?? DesignColors.cyan;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(DesignSpacing.sm),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        SizedBox(width: DesignSpacing.md),
        Text(title, style: DesignTextStyles.screenTitle),
      ],
    );
  }

  Widget _chipsFromMap(Map<String, int> map) {
    if (map.isEmpty) {
      return Text('Sin datos', style: DesignTextStyles.bodyText);
    }
    final entries = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries
          .map(
            (e) => Chip(
              label: Text('${e.key}: ${e.value}'),
              backgroundColor: Colors.white10,
              side: const BorderSide(color: Colors.white24),
            ),
          )
          .toList(),
    );
  }
}
