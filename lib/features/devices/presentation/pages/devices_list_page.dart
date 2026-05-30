import 'package:flutter/material.dart';
import '../../../../core/auth/user_role.dart';
import '../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../widgets/devices_list/device_filter_helpers.dart';
import '../widgets/devices_list/sensor_category_card.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


class DevicesListPage extends StatefulWidget {
  const DevicesListPage({
    super.key,
    required this.role,
    required this.title,
    this.description,
    this.showConfigHint = false,
    this.initialFilter = DeviceTypeFilter.all,
  });

  final UserRole role;
  final String title;
  final String? description;
  final bool showConfigHint;
  final DeviceTypeFilter initialFilter;

  @override
  State<DevicesListPage> createState() => _DevicesListPageState();
}

class _DevicesListPageState extends State<DevicesListPage> {
  late final MonitoringRepository _repository;
  late Future<List<DeviceWithSensorViewModel>> _devicesFuture;
  late Future<List<LatestSensorReadingViewModel>> _latestReadingsFuture;

  late DeviceTypeFilter _filter;

  @override
  void initState() {
    super.initState();
    _repository = MonitoringRepository();
    _devicesFuture = _repository.fetchDevicesWithSensors();
    _latestReadingsFuture = _repository.fetchLatestSensorReadings();
    _filter = widget.initialFilter;
  }

  void _refresh() {
    setState(() {
      _devicesFuture = _repository.fetchDevicesWithSensors();
      _latestReadingsFuture = _repository.fetchLatestSensorReadings();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      floatingActionButton: widget.role == UserRole.admin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed('/devices/create'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Dispositivo'),
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
            )
          : null,
      body: ListView(
        padding: EdgeInsets.all(DesignSpacing.lg),
        children: [
          if (widget.description != null && widget.description!.trim().isNotEmpty) ...[
            Text(widget.description!, style: DesignTextStyles.bodyText),
            SizedBox(height: DesignSpacing.md),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DeviceTypeFilter.values
                .map(
                  (f) => FilterChip(
                    label: Text(f.label),
                    selected: _filter == f,
                    onSelected: (_) {
                      setState(() {
                        _filter = f;
                      });
                    },
                  ),
                )
                .toList(),
          ),
          SizedBox(height: DesignSpacing.md),
          if (widget.showConfigHint) ...[
            Card(
              child: ListTile(
                leading: Icon(Icons.info_outline, color: DesignColors.textPrimary),
                title: Text('Modo configuración', style: DesignTextStyles.cardTitle),
                subtitle: Text(
                  'Próximamente: acciones de alta/edición por tipo y por dispositivo.',
                  style: DesignTextStyles.bodyText,
                ),
              ),
            ),
            SizedBox(height: DesignSpacing.md),
          ],
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              _devicesFuture,
              _latestReadingsFuture,
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final data = snapshot.data;
              if (data == null || data.length < 2) {
                return const Text('No hay dispositivos registrados.');
              }

              final rows = (data[0] as List<DeviceWithSensorViewModel>)
                  .where((r) => _filter.matches(r.deviceType))
                  .toList();
              final latestReadings = data[1] as List<LatestSensorReadingViewModel>;

              if (rows.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: DesignSpacing.sm),
                  child: Text('Sin resultados para filtro: ${_filter.label}'),
                );
              }

              final latestBySensorId = <String, LatestSensorReadingViewModel>{
                for (final r in latestReadings) r.sensorId: r,
              };

              // Queremos mostrar SOLO 3 "tarjetas" (una por categoría), aunque el backend devuelva más sensores.
              final sensors = rows.where((r) => r.sensorId != null).toList();
              final uniqueDeviceIds = rows.map((r) => r.deviceId).toSet();

              final byCategory = <SensorCategory, List<DeviceWithSensorViewModel>>{
                for (final c in SensorCategory.values) c: <DeviceWithSensorViewModel>[],
              };
              for (final s in sensors) {
                byCategory[sensorCategoryOf(s.sensorType)]!.add(s);
              }

              return Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: Icon(_filter.icon, color: Colors.tealAccent),
                      title: Text(
                        'Dispositivos: ${uniqueDeviceIds.length}',
                        style: DesignTextStyles.cardTitle,
                      ),
                      subtitle: Text(
                        'Filtro: ${_filter.label} · Se muestran 3 categorías de sensor',
                        style: DesignTextStyles.bodyText,
                      ),
                    ),
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  ...SensorCategory.values.map((cat) {
                    final list = byCategory[cat] ?? const <DeviceWithSensorViewModel>[];
                    final representative = pickRepresentative(list, latestBySensorId);

                    if (representative == null) {
                      return SizedBox.shrink();
                    }

                    final latest = representative.sensorId == null
                        ? null
                        : latestBySensorId[representative.sensorId!];

                    return SensorCategoryCard(
                      category: cat,
                      representative: representative,
                      sensorsInCategory: list.length,
                      latest: latest,
                      role: widget.role,
                      onDeleted: _refresh,
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
