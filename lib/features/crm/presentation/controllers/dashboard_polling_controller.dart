import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/cache/dashboard_cache_service.dart';
import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../../../features/alerts/data/alerts_repository.dart';
import '../../../../features/alerts/data/models/unified_alert_item.dart';
import '../../../../features/monitoring/data/models/prediction_view_model.dart';
import '../../../../features/monitoring/data/monitoring_repository.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_dashboard_models.dart';
import '../../data/models/crm_devices_models.dart';
import '../widgets/crm_dashboard_models.dart';



class DashboardPollingController {
  DashboardPollingController({
    required this.repo,
    required this.monitoringRepo,
    required this.alertsRepo,
    required this.cacheService,
    required this.lifecycleService,
    this.interval = const Duration(seconds: 30),
  });

  final CrmRepository repo;
  final MonitoringRepository monitoringRepo;
  final AlertsRepository alertsRepo;
  final DashboardCacheService cacheService;
  final AppLifecycleService lifecycleService;
  final Duration interval;

  final dashboardSnapshot = ValueNotifier<SectionSnapshot<CrmDashboardResponse>>(
    const SectionSnapshot<CrmDashboardResponse>(loading: true),
  );
  final predictionsSnapshot = ValueNotifier<SectionSnapshot<List<PredictionViewModel>>>(
    const SectionSnapshot<List<PredictionViewModel>>(loading: true),
  );
  final mlWarningsSnapshot = ValueNotifier<SectionSnapshot<List<UnifiedAlertItem>>>(
    const SectionSnapshot<List<UnifiedAlertItem>>(loading: true),
  );
  final devicesSnapshot = ValueNotifier<SectionSnapshot<List<CrmDeviceSummary>>>(
    const SectionSnapshot<List<CrmDeviceSummary>>(loading: true),
  );

  Timer? _timer;
  bool _paused = false;
  bool _isFetchingDashboard = false;
  bool _isFetchingMl = false;
  StreamSubscription<void>? _pauseSub;
  StreamSubscription<void>? _resumeSub;

  void start() {
    _pauseSub = lifecycleService.onAppPaused.listen((_) {
      if (!_paused) { _paused = true; _timer?.cancel(); _log('polling PAUSED'); }
    });
    _resumeSub = lifecycleService.onAppResumed.listen((_) {
      if (_paused) { _paused = false; _log('polling RESUMED'); refreshAll(); _startTimer(); }
    });
    refreshAll();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => refreshAll());
  }

  void stop() => _timer?.cancel();

  void refreshAll() { _refreshDashboard(); _refreshMl(); _refreshDevices(); }

  void forceRefresh() { invalidateCache(); refreshAll(); }

  void invalidateCache() {
    cacheService.invalidateDashboard();
    cacheService.invalidatePredictions();
    cacheService.invalidateMlAlerts();
  }

  Future<void> _refreshDashboard() async {
    if (_isFetchingDashboard) return;
    _isFetchingDashboard = true;
    final current = dashboardSnapshot.value;
    dashboardSnapshot.value = current.data == null
        ? current.copyWith(loading: true, error: null)
        : current.copyWith(error: null);
    try {
      final cached = cacheService.getDashboard();
      if (cached != null) {
        dashboardSnapshot.value = SectionSnapshot(data: cached, loading: false);
        _isFetchingDashboard = false;
        return;
      }
      final data = await repo.fetchDashboard().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Servidor no responde'),
      );
      cacheService.setDashboard(data);
      dashboardSnapshot.value = SectionSnapshot(data: data, loading: false);
    } catch (e) {
      final after = dashboardSnapshot.value;
      dashboardSnapshot.value = after.copyWith(
        loading: false,
        error: 'Error: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    } finally {
      _isFetchingDashboard = false;
    }
  }

  Future<void> _refreshMl() async {
    if (_isFetchingMl) return;
    _isFetchingMl = true;
    final cP = predictionsSnapshot.value;
    final cW = mlWarningsSnapshot.value;
    final cachedPreds = cacheService.getPredictions();
    final cachedAlerts = cacheService.getMlAlerts();
    if (cachedPreds != null && cachedAlerts != null) {
      predictionsSnapshot.value = SectionSnapshot(data: cachedPreds, loading: false);
      mlWarningsSnapshot.value = SectionSnapshot(data: cachedAlerts, loading: false);
      _isFetchingMl = false;
      return;
    }
    predictionsSnapshot.value = cP.data == null
        ? cP.copyWith(loading: true, error: null) : cP.copyWith(error: null);
    mlWarningsSnapshot.value = cW.data == null
        ? cW.copyWith(loading: true, error: null) : cW.copyWith(error: null);
    try {
      final r = await Future.wait([
        monitoringRepo.fetchPredictions(),
        alertsRepo.fetchImportantMlAlerts(limit: 10),
      ]).timeout(const Duration(seconds: 8));
      final preds = r[0] as List<PredictionViewModel>;
      final warnings = r[1] as List<UnifiedAlertItem>;
      cacheService.setPredictions(preds);
      cacheService.setMlAlerts(warnings);
      predictionsSnapshot.value = SectionSnapshot(data: preds, loading: false);
      mlWarningsSnapshot.value = SectionSnapshot(data: warnings, loading: false);
    } catch (e) {
      final err = e.toString();
      predictionsSnapshot.value = predictionsSnapshot.value.copyWith(loading: false, error: err);
      mlWarningsSnapshot.value = mlWarningsSnapshot.value.copyWith(loading: false, error: err);
    } finally {
      _isFetchingMl = false;
    }
  }

  Future<void> _refreshDevices() async {
    final c = devicesSnapshot.value;
    devicesSnapshot.value = c.data == null ? c.copyWith(loading: true) : c;
    try {
      final r = await repo.listDevices(pageSize: 50);
      devicesSnapshot.value = SectionSnapshot(data: r.items, loading: false);
    } catch (e) {
      devicesSnapshot.value = devicesSnapshot.value.copyWith(
        loading: false,
        error: e.toString().replaceAll('Exception:', '').trim(),
      );
    }
  }

  void dispose() {
    _timer?.cancel();
    _pauseSub?.cancel();
    _resumeSub?.cancel();
    dashboardSnapshot.dispose();
    predictionsSnapshot.dispose();
    mlWarningsSnapshot.dispose();
    devicesSnapshot.dispose();
  }

  void _log(String msg) => debugPrint('[CrmDashboard] $msg');
}
