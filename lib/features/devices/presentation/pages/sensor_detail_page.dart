import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../../../core/theme/design_text_styles.dart';
import '../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../monitoring/data/monitoring_repository.dart';
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
  StreamSubscription<void>? _lifecyclePauseSub;
  StreamSubscription<void>? _lifecycleResumeSub;

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
        _startPolling();

        _lifecyclePauseSub = AppLifecycleService().onAppPaused.listen((_) {
          _poller?.cancel();
        });
        _lifecycleResumeSub = AppLifecycleService().onAppResumed.listen((_) {
          _startPolling();
          _viewModel.refresh(silent: true);
          if (mounted) setState(() {});
        });
      }
    }
  }

  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      if (_viewModel.viewMode == SensorDetailViewMode.frozenFromAlert ||
          _viewModel.viewMode == SensorDetailViewMode.historical) {
        debugPrint(
          '[SensorDetail] Skip refresh: viewMode=${_viewModel.viewMode.name}',
        );
        return;
      }
      _viewModel.refresh(silent: true);
      setState(() {});
    });
  }

  Future<void> _loadInitial() async {
    await _viewModel.loadInitial();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _poller?.cancel();
    _lifecyclePauseSub?.cancel();
    _lifecycleResumeSub?.cancel();
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
        body: Center(
            child: CircularProgressIndicator(color: DesignColors.cyan)),
      );
    }

    if (_viewModel.loadError != null && _viewModel.dashboard == null) {
      return Scaffold(
        appBar: AppBar(title: Text(sensorName)),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(DesignSpacing.xl),
            padding: EdgeInsets.all(DesignSpacing.xl),
            decoration: BoxDecoration(
              color: DesignColors.surface,
              border: Border.all(color: DesignColors.border, width: 0.5),
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: DesignColors.red, size: 32),
                SizedBox(height: DesignSpacing.md),
                Text('Error al cargar datos',
                    style: DesignTextStyles.cardTitle),
                SizedBox(height: DesignSpacing.sm),
                Text(_viewModel.loadError.toString(),
                    style: DesignTextStyles.bodyText),
                SizedBox(height: DesignSpacing.lg),
                ElevatedButton(onPressed: _refresh,
                    child: const Text('Reintentar')),
              ],
            ),
          ),
        ),
      );
    }

    final dashboard = _viewModel.dashboard;
    if (dashboard == null) {
      return Scaffold(
        appBar: AppBar(title: Text(sensorName)),
        body: Center(
            child: Text('Sin datos', style: DesignTextStyles.bodyText)),
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
        sensorName: sensorName,
        role: widget.role,
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
