import 'dart:async';

import '../../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../../monitoring/data/telemetry_repository.dart';
import '../sensor_detail_page.dart';

/// ViewModel for sensor detail page state management
/// Handles polling, data loading, and error states
class SensorDetailViewModel {
  SensorDetailViewModel({
    required this.sensorId,
    required this.viewMode,
    TelemetryRepository? telemetryRepo,
  })  : _telemetryRepo = telemetryRepo ?? TelemetryRepository(),
        _range = '6h';

  final String sensorId;
  final SensorDetailViewMode viewMode;
  final TelemetryRepository _telemetryRepo;
  final String _range;

  SensorDashboardViewModel? _dashboard;
  RealtimePayloadViewModel? _realtimeData;
  Object? _loadError;
  bool _loadingInitial = false;
  bool _refreshing = false;
  bool _fetchInFlight = false;
  DateTime? _lastUpdatedAt;
  String? _lastSeriesTimestamp;
  int _requestGen = 0;

  // Getters
  SensorDashboardViewModel? get dashboard => _dashboard;
  RealtimePayloadViewModel? get realtimeData => _realtimeData;
  Object? get loadError => _loadError;
  bool get loadingInitial => _loadingInitial;
  bool get refreshing => _refreshing;
  DateTime? get lastUpdatedAt => _lastUpdatedAt;

  /// Load initial data
  Future<void> loadInitial() async {
    final gen = ++_requestGen;
    try {
      final realtime = await _telemetryRepo.fetchRealtimeData(sensorId, limit: 120);
      final dashboard = await _telemetryRepo.fetchSensorDashboard(sensorId, range: _range);

      if (gen != _requestGen) return;

      _realtimeData = realtime;
      _dashboard = dashboard;
      _loadError = null;
      _loadingInitial = false;
      _lastUpdatedAt = DateTime.now();
    } catch (e) {
      if (gen != _requestGen) return;
      _loadError = e;
      _loadingInitial = false;
    }
  }

  /// Refresh data (for polling or manual refresh)
  Future<void> refresh({bool silent = false}) async {
    if (_fetchInFlight && silent) return;

    final gen = ++_requestGen;
    _fetchInFlight = true;

    if (!silent && !_refreshing) {
      _refreshing = true;
    }

    try {
      final realtime = await _telemetryRepo.fetchRealtimeData(sensorId, limit: 120);
      final dashboard = await _telemetryRepo.fetchSensorDashboard(sensorId, range: _range);

      if (gen != _requestGen) return;

      final newLastTs = realtime.points.isNotEmpty
          ? realtime.points.last.timestamp
          : null;
      final stateChanged = dashboard.metrics.state != _dashboard?.metrics.state;
      final valueChanged = dashboard.metrics.currentValue != _dashboard?.metrics.currentValue;
      final hasNewData = newLastTs != _lastSeriesTimestamp || valueChanged || stateChanged;

      if (hasNewData || !silent) {
        _realtimeData = realtime;
        _dashboard = dashboard;
        _loadError = null;
        _lastUpdatedAt = DateTime.now();
        _refreshing = false;
        _lastSeriesTimestamp = newLastTs;
      } else if (_refreshing) {
        _refreshing = false;
      }
    } catch (_) {
      if (gen != _requestGen) return;
      if (_refreshing) {
        _refreshing = false;
      }
      if (!silent) rethrow;
    } finally {
      _fetchInFlight = false;
    }
  }

  void dispose() {
    // Cleanup if needed
  }
}
