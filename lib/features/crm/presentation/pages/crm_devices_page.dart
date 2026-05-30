import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/user_role.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_devices_models.dart';
import '../widgets/devices/crm_devices_drawer.dart';
import '../widgets/devices/add_device_dialog.dart';
import '../widgets/devices/crm_device_list_tile.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


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

  Widget _buildEmptyState() {
    final isAdmin = widget.role == UserRole.admin;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.devices_other_outlined,
              size: 64,
              color: DesignColors.textSecondary,
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'No hay dispositivos registrados',
              style: DesignTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              isAdmin
                  ? 'Agrega tu primer dispositivo para comenzar a monitorear.'
                  : 'No tienes dispositivos asignados actualmente.',
              style: DesignTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xl),
            if (isAdmin)
              ElevatedButton.icon(
                onPressed: () => showAddDeviceDialog(
                  context: context,
                  role: widget.role,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Agregar dispositivo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Refrescar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignColors.cyan,
                  side: BorderSide(color: DesignColors.cyan.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
                padding: EdgeInsets.only(right: DesignSpacing.sm),
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
            : Padding(
                padding: EdgeInsets.only(left: DesignSpacing.sm),
                child: Text('Dispositivos', style: DesignTextStyles.screenTitle),
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
            return _buildEmptyState();
          }

          return ListView(
            padding: EdgeInsets.all(DesignSpacing.md),
            children: [
              SizedBox(height: DesignSpacing.xs),
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
