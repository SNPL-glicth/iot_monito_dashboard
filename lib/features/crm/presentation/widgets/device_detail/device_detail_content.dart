import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import '../../../data/models/crm_devices_models.dart';
import '../../pages/crm_device_alerts_page.dart';
import '../../pages/crm_device_history_page.dart';
import 'device_detail_helpers.dart';

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
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.memory, color: statusColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.deviceName,
                        style: DashboardTextStyles.deviceTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(s.status),
                      backgroundColor: Colors.white10,
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('UUID: ${s.deviceUuid}', style: DashboardTextStyles.sensorMeta),
                Text('Tipo: ${s.deviceType}', style: DashboardTextStyles.sensorMeta),
                Text('Sensores: ${s.sensorCount}', style: DashboardTextStyles.sensorMeta),
                Text('Alertas activas: ${s.activeAlerts}', style: DashboardTextStyles.sensorMeta),
                Text('Última conexión: ${formatDateTime(s.lastConnection)}', style: DashboardTextStyles.sensorMeta),
                Text('Última alerta: ${formatDateTime(s.lastAlertAt)}', style: DashboardTextStyles.sensorMeta),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionHeader(icon: Icons.query_stats_outlined, title: 'KPIs del dispositivo', color: Colors.orangeAccent),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rango: ${formatDateTime(data.from)} → ${formatDateTime(data.to)} (bucket: ${data.bucket})',
                  style: DashboardTextStyles.sensorMeta,
                ),
                const SizedBox(height: 8),
                Text('Alertas 24h:', style: DashboardTextStyles.deviceTitle),
                const SizedBox(height: 6),
                _chipsFromMap(data.kpisAlerts24h),
                const SizedBox(height: 12),
                Text('Alertas 7d:', style: DashboardTextStyles.deviceTitle),
                const SizedBox(height: 6),
                _chipsFromMap(data.kpisAlerts7d),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionHeader(icon: Icons.insights, title: 'Histórico y métricas', color: Colors.cyanAccent),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.query_stats_outlined, color: Colors.cyanAccent),
            title: const Text('Ver histórico + métricas', style: DashboardTextStyles.deviceTitle),
            subtitle: Text(
              'Sensores: ${data.sensors.length}\n'
              'Rango: ${formatDateTime(data.from)} → ${formatDateTime(data.to)} (bucket: ${data.bucket})',
              style: DashboardTextStyles.sensorMeta,
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
        const SizedBox(height: 16),
        _sectionHeader(icon: Icons.warning_amber_rounded, title: 'Historial de alertas', color: Colors.redAccent),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.redAccent),
            title: const Text('Ver historial de alertas', style: DashboardTextStyles.deviceTitle),
            subtitle: Text(
              'Alertas activas: ${s.activeAlerts}\n'
              'Última alerta: ${formatDateTime(s.lastAlertAt)}',
              style: DashboardTextStyles.sensorMeta,
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
    final accent = color ?? DashboardColors.sectionAccent;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: DashboardTextStyles.sectionHeader),
      ],
    );
  }

  Widget _chipsFromMap(Map<String, int> map) {
    if (map.isEmpty) {
      return const Text('Sin datos', style: DashboardTextStyles.sensorMeta);
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
