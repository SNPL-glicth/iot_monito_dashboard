import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import 'sensor_detail/sensor_detail_app_bar.dart';
import 'sensor_detail/sensor_detail_page_body.dart';
import 'sensor_detail/sensor_detail_view_model.dart';
import 'sensor_detail/sensor_detail_actions.dart';

enum SensorDetailViewMode {
  realtime,
  frozenFromAlert,
  historical,
}

class SensorDetailPage extends StatefulWidget {
  const SensorDetailPage({
    super.key,
    required this.role,
    required this.row,
    this.latest,
    this.highlightTimestamp,
    this.viewMode = SensorDetailViewMode.realtime,
    this.alertId,
  });

  final UserRole role;
  final DeviceWithSensorViewModel row;
  final dynamic latest;
  final DateTime? highlightTimestamp;
  final SensorDetailViewMode viewMode;
  final String? alertId;

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  late final SensorDetailViewModel _viewModel;
  late final MonitoringRepository _monitoringRepo;
  late final SensorDetailActions _actions;
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    final sensorId = widget.row.sensorId;
    _viewModel = SensorDetailViewModel(
      sensorId: sensorId ?? '',
      viewMode: widget.viewMode,
    );
    _monitoringRepo = MonitoringRepository();
    _actions = SensorDetailActions(
      context: context,
      role: widget.role,
      row: widget.row,
      monitoringRepo: _monitoringRepo,
      onRefresh: _refresh,
    );

    if (sensorId != null && sensorId.isNotEmpty) {
      _loadInitial();
      if (widget.viewMode == SensorDetailViewMode.realtime) {
        _poller = Timer.periodic(const Duration(seconds: 15), (_) {
          if (!mounted) return;
          _viewModel.refresh(silent: true);
          setState(() {});
        });
      }
    }
  }

  Future<void> _loadInitial() async {
    await _viewModel.loadInitial();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _poller?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _viewModel.refresh(silent: false);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sensorName = widget.row.sensorName?.trim().isEmpty ?? true ? '—' : widget.row.sensorName!.trim();
    final unit = widget.row.unit?.trim() ?? '';

    if (_viewModel.loadingInitial && _viewModel.dashboard == null) {
      return Scaffold(
        appBar: AppBar(title: Text(sensorName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_viewModel.loadError != null && _viewModel.dashboard == null) {
      return Scaffold(
        appBar: AppBar(title: Text(sensorName)),
        body: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Error al cargar datos', style: DashboardTextStyles.deviceTitle),
                  const SizedBox(height: 8),
                  Text(_viewModel.loadError.toString(), style: DashboardTextStyles.sensorMeta),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _refresh, child: const Text('Reintentar')),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final dashboard = _viewModel.dashboard;
    if (dashboard == null) {
      return Scaffold(
        appBar: AppBar(title: Text(sensorName)),
        body: const Center(child: Text('Sin datos', style: DashboardTextStyles.sensorMeta)),
      );
    }

    return Scaffold(
      appBar: SensorDetailAppBar(
        role: widget.role,
        row: widget.row,
        onActionSelected: _handleSensorAction,
        onAlertsPressed: _navigateToAlertsHub,
      ),
      body: SensorDetailPageBody(
        dashboard: dashboard,
        realtimeData: _viewModel.realtimeData,
        unit: unit,
        isSensorActive: widget.row.sensorActive == true,
        refreshing: _viewModel.refreshing,
        sensorType: widget.row.sensorType ?? '',
        isFrozen: widget.viewMode != SensorDetailViewMode.realtime,
        deviceName: widget.row.deviceName,
        onDay: () => _openReadingsDay(sensorName, unit),
        onWeek: () => _openReadingsWeek(sensorName, unit),
        onMonth: () => _openMonthPicker(sensorName, unit),
      ),
    );
  }

  void _handleSensorAction(String action) => _actions.handleSensorAction(action);

  Future<void> _openReadingsDay(String sensorName, String unit) => _actions.openReadingsDay(sensorName, unit);

  void _openReadingsWeek(String sensorName, String unit) => _actions.openReadingsWeek(sensorName, unit);

  Future<void> _openMonthPicker(String sensorName, String unit) => _actions.openMonthPicker(sensorName, unit);

  void _navigateToAlertsHub() => _actions.navigateToAlertsHub();
}
