import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../crm/data/crm_repository.dart';
import '../../../crm/data/models/crm_alerts_models.dart';
import '../../../crm/data/models/crm_devices_models.dart';
import '../widgets/alert_future_builder.dart';
import 'alert_detail_page.dart';

/// Página de alertas con prioridad correcta.
/// 
/// REGLAS DE PRIORIDAD:
/// 1. Alertas críticas (rojo) - siempre primero
/// 2. Alertas warning (naranja) - segundo
/// 3. Alertas info (azul) - tercero
/// 
/// Las alertas se ordenan por severidad y luego por fecha (más reciente primero).
class AlertsHubPage extends StatefulWidget {
  const AlertsHubPage({
    super.key,
    required this.role,
  });

  final UserRole role;

  @override
  State<AlertsHubPage> createState() => _AlertsHubPageState();
}

class _AlertsHubPageState extends State<AlertsHubPage> {
  late final CrmRepository _repo;
  late Future<CrmPagedResponse<CrmAlertHistoryItem>> _future;
  
  // Filtro por sensor (null = todos los sensores)
  String? _selectedSensorId;
  String? _selectedSensorName;

  @override
  void initState() {
    super.initState();
    _repo = CrmRepository();
    _loadAlerts();
  }

  void _loadAlerts() {
    // FIX BUG 7: Cargar alertas activas Y acknowledged (no solo active)
    // Las alertas acknowledged siguen siendo relevantes hasta que se resuelvan
    _future = _repo.listAlerts(
      // Sin filtro de status para obtener active + acknowledged
      sensorId: _selectedSensorId,
      pageSize: 200,
    );
  }
  
  void _filterBySensor(String? sensorId, String? sensorName) {
    setState(() {
      _selectedSensorId = sensorId;
      _selectedSensorName = sensorName;
      _loadAlerts();
    });
  }
  
  void _clearFilter() {
    setState(() {
      _selectedSensorId = null;
      _selectedSensorName = null;
      _loadAlerts();
    });
  }

  void _refresh() {
    setState(() {
      _loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        // FIX OBJETIVO 3: Eliminado botón de refresh manual
        // El historial es estable, no requiere refresh constante
      ),
      body: AlertFutureBuilder(
        future: _future,
        selectedSensorId: _selectedSensorId,
        selectedSensorName: _selectedSensorName,
        onFilterBySensor: _filterBySensor,
        onClearFilter: _clearFilter,
        onRefresh: _refresh,
        onAlertTap: (a) async {
          // FASE 4: Navegar a la gráfica del sensor congelada en el timestamp exacto
          final sensorId = a.sensorId;
          if (sensorId == null || sensorId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Alerta sin sensor asociado'),
                backgroundColor: Colors.orangeAccent,
              ),
            );
            return;
          }
          
          // FIX: Refresh on return to reflect status changes
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AlertDetailPage(
                alertId: a.alertId,
                sensorId: sensorId,
                role: widget.role,
              ),
            ),
          );
          // Refresh after returning from detail page
          if (mounted) _refresh();
        },
      ),
      );
  }
}
