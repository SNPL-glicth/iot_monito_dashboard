import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/user_role.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_devices_models.dart';
import '../widgets/devices/crm_devices_drawer.dart';
import '../widgets/devices/add_device_dialog.dart';
import '../widgets/devices/crm_device_list_tile.dart';

class CrmDevicesPage extends StatefulWidget {
  const CrmDevicesPage({
    super.key,
    required this.role,
  });

  final UserRole role;

  @override
  State<CrmDevicesPage> createState() => _CrmDevicesPageState();
}

class _CrmDevicesPageState extends State<CrmDevicesPage> {
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
        q: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        page: 1,
        pageSize: 100,
      );
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

  void _toggleSearch() {
    setState(() {
      _searchMode = !_searchMode;
      if (!_searchMode) {
        _searchController.clear();
        _reload();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CrmDevicesDrawer(
        role: widget.role,
        roleLabel: switch (widget.role) {
          UserRole.admin => 'Administrador',
          UserRole.operator => 'Operador',
          UserRole.viewer => 'Supervisor',
        },
      ),
      appBar: AppBar(
        titleSpacing: 0,
        title: _searchMode
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Buscar dispositivo (nombre/uuid)...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _reload(),
                ),
              )
            : const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('Dispositivos', style: DashboardTextStyles.appBarTitle),
              ),
        actions: [
          IconButton(
            icon: Icon(_searchMode ? Icons.close : Icons.search),
            tooltip: _searchMode ? 'Cerrar búsqueda' : 'Buscar',
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar dispositivo',
            onPressed: widget.role == UserRole.admin
                ? () => showAddDeviceDialog(context: context, role: widget.role)
                : null,
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
            return const Center(child: Text('No hay dispositivos.'));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const SizedBox(height: 4),
              ...items.map((d) => CrmDeviceListTile(
                device: d,
                role: widget.role,
                formatDateTime: _formatDateTime,
              )),
            ],
          );
        },
      ),
    );
  }
}
