import 'package:flutter/material.dart';

import '../../../../core/alerts/alert_snapshot_service.dart';
import '../../../../core/auth/user_role.dart';
import '../../data/alert_detail_cache.dart';
import '../../../crm/data/crm_repository.dart';
import '../../../crm/data/models/crm_alerts_models.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../widgets/alert_detail_widgets.dart';
import '../widgets/alert_detail_body.dart';

/// Página de detalle de alerta con gráfica CONGELADA.
/// 
/// FASE 1: Esta página NO tiene polling ni refresh automático.
/// Muestra el estado exacto al momento de la alerta.
/// 
/// Diferencias con SensorDetailPage:
/// - Sin Timer de polling
/// - Sin botón de refresh manual
/// - Gráfica congelada (FrozenAlertChart)
/// - Datos inmutables del snapshot
class AlertDetailPage extends StatefulWidget {
  const AlertDetailPage({
    super.key,
    required this.alertId,
    required this.sensorId,
    this.role = UserRole.viewer,
    this.preloadedSnapshot,
  });

  final String alertId;
  final String sensorId;
  final UserRole role;
  final AlertSnapshot? preloadedSnapshot;

  @override
  State<AlertDetailPage> createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  final MonitoringRepository _repo = MonitoringRepository();
  final AlertSnapshotService _snapshotService = AlertSnapshotService();
  final CrmRepository _crmRepo = CrmRepository();

  final _alertCache = AlertDetailCache();
  AlertSnapshot? _snapshot;
  CrmAlertHistoryItem? _alertHistory;
  bool _loading = true;
  String? _error;
  bool _isAcknowledged = false;
  bool _acknowledging = false;
  bool _isResolved = false;
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[AlertDetail] ========== INIT STATE ==========');
    debugPrint('[AlertDetail] alertId=${widget.alertId}, sensorId=${widget.sensorId}');
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    debugPrint('[AlertDetail] _loadSnapshot() called for alertId=${widget.alertId}, sensorId=${widget.sensorId}');
    
    // Si ya tenemos un snapshot precargado, usarlo
    if (widget.preloadedSnapshot != null) {
      debugPrint('[AlertDetail] Using preloaded snapshot with ${widget.preloadedSnapshot!.points.length} points');
      if (widget.preloadedSnapshot!.points.isEmpty) {
        debugPrint('[AlertDetail] WARNING: Preloaded snapshot is EMPTY, ignoring it');
      } else {
        setState(() {
          _snapshot = widget.preloadedSnapshot;
          _loading = false;
        });
        return;
      }
    }

    // Verificar cache
    final cached = _snapshotService.getCachedSnapshot(widget.alertId);
    if (cached != null) {
      debugPrint('[AlertDetail] Using cached snapshot with ${cached.points.length} points');
      setState(() {
        _snapshot = cached;
        _loading = false;
      });
      return;
    }
    
    debugPrint('[AlertDetail] No cache/preload, loading from API...');

    // FIX ARQUITECTÓNICO: Cargar datos de la alerta
    // Intenta snapshot inmutable primero, fallback a historical readings
    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('[AlertDetail] Loading data for alertId=${widget.alertId}');
      
      // PASO 1: Obtener datos de la alerta (cache o endpoint lazy)
      var alertHistory = _alertCache.get(widget.alertId);
      if (alertHistory == null) {
        alertHistory = await _crmRepo.getAlertById(widget.alertId);
        if (alertHistory != null) _alertCache.set(widget.alertId, alertHistory);
      }

      if (alertHistory == null) {
        setState(() {
          _error = 'No se encontró la alerta.\nID: ${widget.alertId}';
          _loading = false;
        });
        return;
      }

      setState(() {
        _alertHistory = alertHistory;
        _isAcknowledged = alertHistory!.status.toLowerCase() == 'acknowledged';
        _isResolved = alertHistory.status.toLowerCase() == 'resolved';
      });

      debugPrint('[AlertDetail] Alert found: severity=${alertHistory.severity}, triggeredAt=${alertHistory.triggeredAt}');
      
      // PASO 2: Usar triggeredAt como FUENTE DE VERDAD
      final triggeredAt = DateTime.tryParse(alertHistory.triggeredAt) ?? DateTime.now();
      final triggeredValue = double.tryParse(alertHistory.triggeredValue) ?? 0.0;
      final severity = alertHistory.severity.toLowerCase();
      
      // PASO 3: Intentar obtener snapshot inmutable (si existe la tabla)
      AlertSnapshot? snapshot;
      try {
        final snapshotResponse = await _crmRepo.getAlertSnapshot(int.parse(widget.alertId));
        if (snapshotResponse.series.isNotEmpty) {
          debugPrint('[AlertDetail] Using IMMUTABLE snapshot: ${snapshotResponse.pointCount} points');
          snapshot = _snapshotService.createSnapshotFromTradingSeries(
            alertId: widget.alertId,
            sensorId: snapshotResponse.sensorId,
            sensorName: snapshotResponse.sensorName,
            deviceName: snapshotResponse.deviceName,
            unit: snapshotResponse.unit ?? '',
            severity: snapshotResponse.severity.toLowerCase(),
            triggeredValue: snapshotResponse.triggeredValue,
            triggeredAt: DateTime.tryParse(snapshotResponse.triggeredAt) ?? triggeredAt,
            tradingSeries: snapshotResponse.series.map((p) => <String, dynamic>{
              'timestamp': p.timestamp,
              'value': p.value,
              'state': p.state,
            }).toList(),
            thresholdMin: snapshotResponse.thresholds.alertMin,
            thresholdMax: snapshotResponse.thresholds.alertMax,
            warningMin: snapshotResponse.thresholds.warningMin,
            warningMax: snapshotResponse.thresholds.warningMax,
          );
        }
      } catch (snapshotError) {
        debugPrint('[AlertDetail] Snapshot not available, using fallback: $snapshotError');
      }
      
      // PASO 4: Fallback a historical readings si no hay snapshot
      if (snapshot == null) {
        debugPrint('[AlertDetail] Using HISTORICAL READINGS fallback');
        debugPrint('[AlertDetail] SensorId: ${widget.sensorId}');
        debugPrint('[AlertDetail] TriggeredAt: $triggeredAt');
        
        const contextBefore = Duration(minutes: 30);
        const contextAfter = Duration(minutes: 5);
        final fromDate = triggeredAt.subtract(contextBefore);
        final toDate = triggeredAt.add(contextAfter);
        
        debugPrint('[AlertDetail] Fetching from $fromDate to $toDate');
        
        try {
          final historicalData = await _repo.fetchHistoricalReadings(
            widget.sensorId,
            from: fromDate,
            to: toDate,
            limit: 500,
          );
          
          debugPrint('[AlertDetail] Historical data received: ${historicalData.series.length} points');
          
          if (historicalData.series.isEmpty) {
            debugPrint('[AlertDetail] WARNING: No historical data found!');
            // Crear snapshot vacío con al menos el punto trigger
            snapshot = AlertSnapshot(
              alertId: widget.alertId,
              sensorId: widget.sensorId,
              sensorName: alertHistory.sensorName ?? 'Sensor',
              deviceName: alertHistory.deviceName,
              unit: alertHistory.unit ?? '',
              severity: severity,
              triggeredValue: triggeredValue,
              triggeredAt: triggeredAt,
              points: [
                AlertSnapshotPoint(
                  timestamp: triggeredAt,
                  value: triggeredValue,
                  isAlertTrigger: true,
                  state: severity.toUpperCase(),
                ),
              ],
              thresholdMin: double.tryParse(alertHistory.thresholdValueMin ?? ''),
              thresholdMax: double.tryParse(alertHistory.thresholdValueMax ?? ''),
              message: 'Datos históricos no disponibles. Mostrando solo el punto de alerta.',
            );
          } else {
            snapshot = _snapshotService.createSnapshotFromTradingSeries(
              alertId: widget.alertId,
              sensorId: widget.sensorId,
              sensorName: alertHistory.sensorName ?? historicalData.sensorName,
              deviceName: alertHistory.deviceName,
              unit: alertHistory.unit ?? historicalData.unit,
              severity: severity,
              triggeredValue: triggeredValue,
              triggeredAt: triggeredAt,
              tradingSeries: historicalData.series.map((p) => <String, dynamic>{
                'timestamp': p.timestamp,
                'value': p.value,
                'state': p.state,
              }).toList(),
              thresholdMin: double.tryParse(alertHistory.thresholdValueMin ?? '') ?? historicalData.thresholds.alertMin,
              thresholdMax: double.tryParse(alertHistory.thresholdValueMax ?? '') ?? historicalData.thresholds.alertMax,
              warningMin: historicalData.thresholds.warningMin,
              warningMax: historicalData.thresholds.warningMax,
            );
            debugPrint('[AlertDetail] Snapshot created with ${snapshot.points.length} points');
          }
        } catch (histError) {
          debugPrint('[AlertDetail] Error fetching historical: $histError');
          // Crear snapshot mínimo con el punto trigger
          snapshot = AlertSnapshot(
            alertId: widget.alertId,
            sensorId: widget.sensorId,
            sensorName: alertHistory.sensorName ?? 'Sensor',
            deviceName: alertHistory.deviceName,
            unit: alertHistory.unit ?? '',
            severity: severity,
            triggeredValue: triggeredValue,
            triggeredAt: triggeredAt,
            points: [
              AlertSnapshotPoint(
                timestamp: triggeredAt,
                value: triggeredValue,
                isAlertTrigger: true,
                state: severity.toUpperCase(),
              ),
            ],
            thresholdMin: double.tryParse(alertHistory.thresholdValueMin ?? ''),
            thresholdMax: double.tryParse(alertHistory.thresholdValueMax ?? ''),
            message: 'Error cargando datos históricos: $histError',
          );
        }
      }
      
      debugPrint('[AlertDetail] Snapshot ready with ${snapshot.points.length} points in ${stopwatch.elapsedMilliseconds}ms');

      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (e, stack) {
      debugPrint('[AlertDetail] ERROR: $e');
      debugPrint('[AlertDetail] Stack: $stack');
      setState(() {
        _error = 'Error cargando datos de la alerta:\n$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Alerta'),
        actions: [
          AlertDetailWidgets.frozenIndicator(),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return AlertDetailWidgets.errorWidget(_error!);
    }

    if (_snapshot == null) {
      return const Center(child: Text('Sin datos'));
    }

    return AlertDetailBody(
      snapshot: _snapshot!,
      role: widget.role,
      alertId: widget.alertId,
      crmRepo: _crmRepo,
      acknowledging: _acknowledging,
      isAcknowledged: _isAcknowledged,
      onAcknowledgeChanged: (loading) => setState(() => _acknowledging = loading),
      resolving: _resolving,
      isResolved: _isResolved,
      onResolveChanged: (loading) => setState(() => _resolving = loading),
      onOptimisticAck: () => setState(() => _isAcknowledged = true),
      onRevertAck: () => setState(() => _isAcknowledged = _alertHistory?.status.toLowerCase() == 'acknowledged'),
      onOptimisticResolve: () => setState(() => _isResolved = true),
      onRevertResolve: () => setState(() => _isResolved = _alertHistory?.status.toLowerCase() == 'resolved'),
    );
  }
}
