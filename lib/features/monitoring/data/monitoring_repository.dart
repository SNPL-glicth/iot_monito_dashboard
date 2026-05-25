import '../../../core/network/api_client.dart';
import 'models/device_with_sensor_view_model.dart';
import 'models/monitoring_view_models.dart';
import 'models/prediction_view_model.dart';
import 'models/sensor_consolidated_status_view_model.dart';
import 'repositories/monitoring_cache.dart';
import 'repositories/monitoring_sensor_repository.dart';
import 'repositories/monitoring_threshold_ops.dart';
import 'repositories/monitoring_readings_ops.dart';
import 'repositories/monitoring_predictions_alerts_ops.dart';
import 'repositories/monitoring_dashboard_ops.dart';

// este repositorio junta todas las llamadas del dashboard al backend
// SINGLETON: Evita crear múltiples instancias que causan memory leaks
class MonitoringRepository {
  // Singleton instance
  static final MonitoringRepository _instance = MonitoringRepository._internal();
  
  // Factory constructor retorna siempre la misma instancia
  factory MonitoringRepository([ApiClient? apiClient]) => _instance;
  
  // Constructor privado interno
  MonitoringRepository._internal() : _apiClient = ApiClient() {
    _sensorRepo = MonitoringSensorRepository(_apiClient);
    _thresholdOps = MonitoringThresholdOps(_apiClient);
    _readingsOps = MonitoringReadingsOps(_apiClient);
    _predictionsAlertsOps = MonitoringPredictionsAlertsOps(_apiClient);
    _dashboardOps = MonitoringDashboardOps(_apiClient);
  }

  final ApiClient _apiClient;
  late final MonitoringSensorRepository _sensorRepo;
  late final MonitoringThresholdOps _thresholdOps;
  late final MonitoringReadingsOps _readingsOps;
  late final MonitoringPredictionsAlertsOps _predictionsAlertsOps;
  late final MonitoringDashboardOps _dashboardOps;

  // Delegados a MonitoringSensorRepository
  Future<List<DeviceWithSensorViewModel>> fetchDevicesWithSensors() => 
      _sensorRepo.fetchDevicesWithSensors();
  Future<SensorConsolidatedStatusViewModel> fetchSensorStatus(String sensorId) => 
      _sensorRepo.fetchSensorStatus(sensorId);
  Future<void> updateSensor(String sensorId, {String? name}) => 
      _sensorRepo.updateSensor(sensorId, name: name);
  Future<String> deleteSensor(String sensorId) => 
      _sensorRepo.deleteSensor(sensorId);
  Future<Map<String, SensorConsolidatedStatusViewModel>> fetchSensorStatusBatch(List<String> sensorIds) => 
      _sensorRepo.fetchSensorStatusBatch(sensorIds);

  // Delegados a MonitoringReadingsOps
  Future<List<LatestSensorReadingViewModel>> fetchLatestSensorReadings() => 
      _readingsOps.fetchLatestSensorReadings();
  Future<List<SensorReadingViewModel>> fetchSensorReadings(String sensorId, {int limit = 50, DateTime? from, DateTime? to}) => 
      _readingsOps.fetchSensorReadings(sensorId, limit: limit, from: from, to: to);
  Future<RawSensorReadingsViewModel> fetchRawSensorReadings(String sensorId, {int limit = 500, DateTime? since}) => 
      _readingsOps.fetchRawSensorReadings(sensorId, limit: limit, since: since);
  Future<AggregatedSensorReadingsViewModel> fetchAggregatedSensorReadings(String sensorId, {String range = '6h'}) => 
      _readingsOps.fetchAggregatedSensorReadings(sensorId, range: range);
  Future<HistoricalReadingsViewModel> fetchHistoricalReadings(String sensorId, {required DateTime from, required DateTime to, int limit = 500}) => 
      _readingsOps.fetchHistoricalReadings(sensorId, from: from, to: to, limit: limit);

  // Delegados a MonitoringThresholdOps
  Future<SensorThresholdProfileViewModel> fetchSensorThresholdProfile(String sensorId) => 
      _thresholdOps.fetchSensorThresholdProfile(sensorId);
  Future<SensorThresholdProfileViewModel> updateSensorThresholdProfile(String sensorId, {String? warningMin, String? warningMax, String? alertMin, String? alertMax, int? cooldownSeconds}) => 
      _thresholdOps.updateSensorThresholdProfile(sensorId, warningMin: warningMin, warningMax: warningMax, alertMin: alertMin, alertMax: alertMax, cooldownSeconds: cooldownSeconds);
  Future<List<AlertThresholdViewModel>> fetchSensorThresholds(String sensorId) => 
      _thresholdOps.fetchSensorThresholds(sensorId);
  Future<AlertThresholdViewModel> createSensorThreshold(String sensorId, {required String name, required String conditionType, String? thresholdValueMin, String? thresholdValueMax, String severity = 'warning'}) => 
      _thresholdOps.createSensorThreshold(sensorId, name: name, conditionType: conditionType, thresholdValueMin: thresholdValueMin, thresholdValueMax: thresholdValueMax, severity: severity);
  Future<AlertThresholdViewModel> updateThreshold(String thresholdId, {String? thresholdValueMin, String? thresholdValueMax, String? severity, String? name, String? reason}) => 
      _thresholdOps.updateThreshold(thresholdId, thresholdValueMin: thresholdValueMin, thresholdValueMax: thresholdValueMax, severity: severity, name: name, reason: reason);
  Future<void> deactivateThreshold(String thresholdId, {String? reason}) => 
      _thresholdOps.deactivateThreshold(thresholdId, reason: reason);
  Future<List<ThresholdHistoryViewModel>> fetchThresholdHistory(String thresholdId) => 
      _thresholdOps.fetchThresholdHistory(thresholdId);

  // Delegados a MonitoringPredictionsAlertsOps
  Future<List<ActiveAlertViewModel>> fetchActiveAlerts() => 
      _predictionsAlertsOps.fetchActiveAlerts();
  Future<List<PredictionViewModel>> fetchPredictions() => 
      _predictionsAlertsOps.fetchPredictions();

  // Delegados a MonitoringDashboardOps
  Future<SensorMetricsViewModel> fetchSensorMetrics(String sensorId, {String window = '1h'}) => 
      _dashboardOps.fetchSensorMetrics(sensorId, window: window);
  Future<SensorDashboardViewModel> fetchSensorDashboard(String sensorId, {String range = '6h', bool forceRefresh = false}) => 
      _dashboardOps.fetchSensorDashboard(sensorId, range: range, forceRefresh: forceRefresh);

  // Delegados a MonitoringCache
  void invalidateDashboardCache(String sensorId) => 
      MonitoringCache.invalidateDashboardCache(sensorId);
  void invalidateAllCache() => 
      MonitoringCache.invalidateAllCache();
  void invalidatePredictionsCache() => 
      MonitoringCache.invalidatePredictionsCache();
  void invalidateActiveAlertsCache() => 
      MonitoringCache.invalidateActiveAlertsCache();
}
