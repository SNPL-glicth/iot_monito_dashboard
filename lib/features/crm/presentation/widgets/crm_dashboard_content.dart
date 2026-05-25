import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/cache/dashboard_cache_service.dart';
import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../../monitoring/data/models/prediction_view_model.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../../../alerts/data/alerts_repository.dart';
import '../../../alerts/data/models/unified_alert_item.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_dashboard_models.dart';
import 'crm_dashboard_models.dart';
import 'crm_dashboard_helpers.dart';
import 'crm_dashboard/crm_alert_queue.dart';
import 'crm_dashboard/crm_kpis_section.dart';
import 'crm_dashboard/crm_ml_predictions_panel.dart';
import 'crm_dashboard/crm_recent_events.dart';
import 'crm_dashboard/crm_welcome_header.dart';

class CrmDashboardContent extends StatefulWidget {
  const CrmDashboardContent({
    super.key,
    required this.role,
    this.repository,
  });

  final UserRole role;
  final CrmRepository? repository;

  @override
  CrmDashboardContentState createState() => CrmDashboardContentState();
}

class CrmDashboardContentState extends State<CrmDashboardContent> {
  late final CrmRepository _repo;
  late final MonitoringRepository _monitoringRepo;
  late final AlertsRepository _alertsRepo;

  // Estado reactivo por sección (sin setState global en el Timer)
  // FIX MEMORY LEAK: Estos ValueNotifiers se liberan en dispose()
  final ValueNotifier<SectionSnapshot<CrmDashboardResponse>> _dashboardSnapshot =
      ValueNotifier<SectionSnapshot<CrmDashboardResponse>>(
    const SectionSnapshot<CrmDashboardResponse>(loading: true),
  );

  final ValueNotifier<SectionSnapshot<List<PredictionViewModel>>>
      _predictionsSnapshot =
          ValueNotifier<SectionSnapshot<List<PredictionViewModel>>>(
    const SectionSnapshot<List<PredictionViewModel>>(loading: true),
  );

  final ValueNotifier<SectionSnapshot<List<UnifiedAlertItem>>>
      _mlWarningsSnapshot =
          ValueNotifier<SectionSnapshot<List<UnifiedAlertItem>>>(
    const SectionSnapshot<List<UnifiedAlertItem>>(loading: true),
  );

  // FIX FASE 2: Usar servicio de cache centralizado
  final DashboardCacheService _cacheService = DashboardCacheService();

  Timer? _pollTimer;
  bool _isFetchingDashboard = false;
  bool _isFetchingMl = false;
  bool _pollingPaused = false;
  StreamSubscription<void>? _lifecyclePauseSub;
  StreamSubscription<void>? _lifecycleResumeSub;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? CrmRepository();
    _monitoringRepo = MonitoringRepository();
    _alertsRepo = AlertsRepository();

    _lifecyclePauseSub = AppLifecycleService().onAppPaused.listen((_) {
      if (!_pollingPaused) {
        _pollingPaused = true;
        _pollTimer?.cancel();
        debugPrint('[CrmDashboard] polling PAUSED (lifecycle service)');
      }
    });
    _lifecycleResumeSub = AppLifecycleService().onAppResumed.listen((_) {
      if (_pollingPaused) {
        _pollingPaused = false;
        debugPrint('[CrmDashboard] polling RESUMED');
        _refreshDashboard();
        _refreshMlSections();
        _startPolling();
      }
    });

    // Carga inmediata: skeleton se muestra en el primer frame,
    // datos se piden justo después sin delays artificiales.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint('[CrmDashboard] initState - starting immediate load');
      _refreshDashboard();
      _refreshMlSections();
      _startPolling();
    });
  }

  void _startPolling() {
    // Polling cada 30 segundos (era 3s, causaba freeze por acumulación de requests)
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      _refreshDashboard();
      _refreshMlSections();
    });
  }

  Future<void> _refreshDashboard() async {
    // Evitar llamadas simultáneas
    if (_isFetchingDashboard) return;
    _isFetchingDashboard = true;
    
    final current = _dashboardSnapshot.value;
    // Solo mostramos loading en el primer fetch (cuando aún no hay datos).
    if (current.data == null) {
      _dashboardSnapshot.value =
          current.copyWith(loading: true, error: null);
    } else {
      _dashboardSnapshot.value = current.copyWith(error: null);
    }

    try {
      // FIX FASE 2: Usar servicio de cache centralizado
      final cached = _cacheService.getDashboard();
      if (cached != null) {
        _dashboardSnapshot.value =
            SectionSnapshot<CrmDashboardResponse>(data: cached, loading: false);
        _isFetchingDashboard = false;
        return;
      }

      // FIX FREEZE: Timeout corto para evitar que la UI se congele
      debugPrint('[CrmDashboard] fetching dashboard from API...');
      final data = await _repo.fetchDashboard()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('[CrmDashboard] dashboard fetch TIMEOUT');
        throw TimeoutException('Servidor no responde');
      });
      debugPrint('[CrmDashboard] dashboard fetch SUCCESS');
      
      // Actualizar cache centralizado
      _cacheService.setDashboard(data);
      
      _dashboardSnapshot.value =
          SectionSnapshot<CrmDashboardResponse>(data: data, loading: false);
    } catch (e) {
      debugPrint('[CrmDashboard] dashboard fetch ERROR: $e');
      // Si ya había datos, mantenemos la última versión buena
      final after = _dashboardSnapshot.value;
      _dashboardSnapshot.value = after.copyWith(
        loading: false,
        error: 'Error de conexión: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    } finally {
      _isFetchingDashboard = false;
    }
  }

  Future<void> _refreshMlSections() async {
    // Evitar llamadas simultáneas
    if (_isFetchingMl) return;
    _isFetchingMl = true;
    final currentPreds = _predictionsSnapshot.value;
    final currentWarnings = _mlWarningsSnapshot.value;

    // FIX FASE 2: Verificar cache primero
    final cachedPreds = _cacheService.getPredictions();
    final cachedAlerts = _cacheService.getMlAlerts();
    
    if (cachedPreds != null && cachedAlerts != null) {
      _predictionsSnapshot.value = SectionSnapshot<List<PredictionViewModel>>(
        data: cachedPreds,
        loading: false,
      );
      _mlWarningsSnapshot.value = SectionSnapshot<List<UnifiedAlertItem>>(
        data: cachedAlerts,
        loading: false,
      );
      _isFetchingMl = false;
      return;
    }

    // Solo mostramos loading si todavía no hay datos en esa sección.
    _predictionsSnapshot.value = currentPreds.data == null
        ? currentPreds.copyWith(loading: true, error: null)
        : currentPreds.copyWith(error: null);
    _mlWarningsSnapshot.value = currentWarnings.data == null
        ? currentWarnings.copyWith(loading: true, error: null)
        : currentWarnings.copyWith(error: null);

    try {
      // FIX FREEZE: Timeout para evitar que la UI se congele
      final results = await Future.wait([
        _monitoringRepo.fetchPredictions(),
        _alertsRepo.fetchImportantMlAlerts(limit: 10),
      ]).timeout(const Duration(seconds: 8), onTimeout: () {
        throw TimeoutException('ML sections tardaron demasiado en cargar');
      });
      final preds = results[0] as List<PredictionViewModel>;
      final warnings = results[1] as List<UnifiedAlertItem>;

      // Actualizar cache centralizado
      _cacheService.setPredictions(preds);
      _cacheService.setMlAlerts(warnings);

      _predictionsSnapshot.value = SectionSnapshot<List<PredictionViewModel>>(
        data: preds,
        loading: false,
      );
      _mlWarningsSnapshot.value = SectionSnapshot<List<UnifiedAlertItem>>(
        data: warnings,
        loading: false,
      );
    } catch (e) {
      final err = e.toString();
      _predictionsSnapshot.value =
          _predictionsSnapshot.value.copyWith(loading: false, error: err);
      _mlWarningsSnapshot.value =
          _mlWarningsSnapshot.value.copyWith(loading: false, error: err);
    } finally {
      _isFetchingMl = false;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _lifecyclePauseSub?.cancel();
    _lifecycleResumeSub?.cancel();
    // FIX MEMORY LEAK: Liberar ValueNotifiers
    _dashboardSnapshot.dispose();
    _predictionsSnapshot.dispose();
    _mlWarningsSnapshot.dispose();
    super.dispose();
  }

  /// Método público para refrescar desde CrmHomePage (evita polling duplicado)
  void refreshAll() {
    // Invalidar cache para forzar refresh real
    _cacheService.invalidateDashboard();
    _cacheService.invalidatePredictions();
    _cacheService.invalidateMlAlerts();
    _refreshDashboard();
    _refreshMlSections();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: ValueListenableBuilder<SectionSnapshot<CrmDashboardResponse>>(
        valueListenable: _dashboardSnapshot,
        builder: (context, snapshot, _) {
          if (snapshot.loading && snapshot.data == null) {
            return _buildSkeleton();
          }

          if (snapshot.error != null && snapshot.data == null) {
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  'Error cargando dashboard: ${snapshot.error}',
                  style: DashboardTextStyles.error,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Sin datos.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo y fecha
              CrmWelcomeHeader(data: data),
              const SizedBox(height: 20),

              // KPIs en grid moderno
              CrmKpisSection(data: data),
              const SizedBox(height: 24),

              // Sección ML con diseño moderno
              CrmDashboardHelpers.sectionHeader(
                icon: Icons.auto_awesome,
                title: 'Inteligencia Artificial',
                color: DashboardColors.primary,
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<SectionSnapshot<List<UnifiedAlertItem>>>(
                valueListenable: _mlWarningsSnapshot,
                builder: (context, warnSnap, _) {
                  final warnings = warnSnap.data ?? const <UnifiedAlertItem>[];
                  return ValueListenableBuilder<SectionSnapshot<List<PredictionViewModel>>>(
                    valueListenable: _predictionsSnapshot,
                    builder: (context, predSnap, _) {
                      final predictions = predSnap.data ?? const <PredictionViewModel>[];
                      return CrmMlPredictionsPanel(
                        warnings: warnings,
                        predictions: predictions,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Alertas activas
              CrmDashboardHelpers.sectionHeader(
                icon: Icons.notifications_active_outlined,
                title: 'Alertas Activas',
                color: DashboardColors.error,
              ),
              const SizedBox(height: 12),
              CrmAlertQueue(items: data.alertQueue),
              const SizedBox(height: 24),

              // Eventos recientes
              CrmDashboardHelpers.sectionHeader(
                icon: Icons.timeline_outlined,
                title: 'Actividad Reciente',
                color: DashboardColors.info,
              ),
              const SizedBox(height: 12),
              CrmRecentEvents(items: data.recentEvents),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  /// Skeleton loader que replica exactamente el layout del dashboard real:
  /// header, KPIs (4 cards), ML panel, alertas y actividad reciente.
  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        _SkeletonLine(width: 220, height: 24),
        const SizedBox(height: 8),
        _SkeletonLine(width: 160, height: 14),
        const SizedBox(height: 20),

        // KPIs skeleton (2x2 grid)
        Row(
          children: [
            Expanded(child: _SkeletonCard(height: 90)),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonCard(height: 90)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SkeletonCard(height: 90)),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonCard(height: 90)),
          ],
        ),
        const SizedBox(height: 24),

        // ML section header skeleton
        _SkeletonLine(width: 180, height: 18),
        const SizedBox(height: 12),
        _SkeletonCard(height: 140),
        const SizedBox(height: 24),

        // Alertas header skeleton
        _SkeletonLine(width: 140, height: 18),
        const SizedBox(height: 12),
        _SkeletonCard(height: 80),
        const SizedBox(height: 24),

        // Actividad reciente header skeleton
        _SkeletonLine(width: 160, height: 18),
        const SizedBox(height: 12),
        _SkeletonCard(height: 80),
        const SizedBox(height: 32),
      ],
    );
  }

}

/// Placeholder de línea para textos del skeleton.
class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DashboardColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Placeholder de card para secciones del skeleton.
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: DashboardColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonLine(width: 80, height: 12),
            SizedBox(height: 12),
            _SkeletonLine(width: double.infinity, height: 10),
            SizedBox(height: 8),
            _SkeletonLine(width: 140, height: 10),
          ],
        ),
      ),
    );
  }
}
