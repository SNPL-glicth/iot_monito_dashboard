import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/user_role.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_devices_models.dart';
import 'crm_device_details_page.dart';

class CrmDeviceTypePage extends StatefulWidget {
  const CrmDeviceTypePage({
    super.key,
    required this.role,
    required this.deviceType,
  });

  final UserRole role;
  final String deviceType;

  @override
  State<CrmDeviceTypePage> createState() => _CrmDeviceTypePageState();
}

class _CrmDeviceTypePageState extends State<CrmDeviceTypePage> {
  final _searchController = TextEditingController();
  bool _searchMode = false;

  late final CrmRepository _repo;
  late Future<CrmPagedResponse<CrmDeviceSummary>> _future;

  @override
  void initState() {
    super.initState();
    _repo = CrmRepository();
    _reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _repo.listDevices(
        type: widget.deviceType,
        q: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        page: 1,
        pageSize: 200,
      );
    });
  }

  void _toggleSearch() {
    setState(() {
      _searchMode = !_searchMode;
      if (!_searchMode) {
        _searchController.clear();
        _reload();
      }
    });
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(iso.toLocal());
    }
    return raw;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.greenAccent;
      case 'offline':
        return Colors.redAccent;
      case 'maintenance':
        return Colors.orangeAccent;
      case 'error':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _typeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('electric') || t.contains('eléctr') || t.contains('electr')) {
      return Icons.electrical_services_outlined;
    }
    if (t.contains('frigo')) {
      return Icons.ac_unit_outlined;
    }
    if (t.contains('ambient') || t.contains('clima')) {
      return Icons.thermostat_outlined;
    }
    return Icons.devices_other_outlined;
  }

  String get _title {
    final t = widget.deviceType.trim().toLowerCase();
    if (t.contains('electric') || t.contains('eléctr') || t.contains('electr')) {
      return 'Medidores eléctricos';
    }
    if (t.contains('frigo')) {
      return 'Frigoríficos';
    }
    if (t.contains('ambient') || t.contains('clima')) {
      return 'Sensores ambientales';
    }
    return widget.deviceType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _searchMode
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Buscar dentro del tipo...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _reload(),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Icon(_typeIcon(widget.deviceType), color: Colors.tealAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_title, style: DashboardTextStyles.appBarTitle),
                    ),
                  ],
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_searchMode ? Icons.close : Icons.search),
            tooltip: _searchMode ? 'Cerrar búsqueda' : 'Buscar',
            onPressed: _toggleSearch,
          ),
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: FutureBuilder<CrmPagedResponse<CrmDeviceSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final page = snapshot.data;
          final items = page?.items ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No hay dispositivos de este tipo.'));
          }

          final total = items.length;
          final online = items.where((d) => d.status.toLowerCase() == 'online').length;
          final offline = items.where((d) => d.status.toLowerCase() == 'offline').length;

          String typeLabel(String raw) {
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

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen', style: DashboardTextStyles.deviceTitle),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text('Disponibles: $total'),
                            backgroundColor: Colors.white10,
                            side: const BorderSide(color: Colors.white24),
                          ),
                          Chip(
                            label: Text('Online: $online'),
                            backgroundColor: Colors.white10,
                            side: const BorderSide(color: Colors.white24),
                          ),
                          Chip(
                            label: Text('Offline: $offline'),
                            backgroundColor: Colors.white10,
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Toca un dispositivo para ver sus sensores y métricas específicas.',
                        style: DashboardTextStyles.sensorMeta,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((d) {
                final statusColor = _statusColor(d.status);
                final id = int.tryParse(d.deviceId);

                return Card(
                  child: ListTile(
                    leading: Icon(_typeIcon(d.deviceType), color: statusColor),
                    title: Text(d.deviceName, style: DashboardTextStyles.deviceTitle),
                    subtitle: Text(
                      'Tipo: ${typeLabel(d.deviceType)} · Estado: ${d.status} · Sensores: ${d.sensorCount} · Alertas activas: ${d.activeAlerts}\n'
                      'Última conexión: ${_formatDateTime(d.lastConnection)}',
                      style: DashboardTextStyles.sensorMeta,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: id == null
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CrmDeviceDetailsPage(
                                  role: widget.role,
                                  deviceId: id,
                                  deviceNameHint: d.deviceName,
                                ),
                              ),
                            );
                          },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
