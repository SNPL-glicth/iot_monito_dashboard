import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/auth/user_role.dart';
import '../../../../core/cache/dashboard_cache_service.dart';
import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_dashboard_models.dart';
import '../../data/models/crm_devices_models.dart';
import 'crm_dashboard_models.dart';
import '../controllers/dashboard_polling_controller.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../../../monitoring/data/models/prediction_view_model.dart';
import '../../../alerts/data/alerts_repository.dart';
import '../../../alerts/data/models/unified_alert_item.dart';
import 'crm_dashboard/crm_alert_queue.dart';
import 'crm_dashboard/crm_ml_predictions_panel.dart';
import 'crm_dashboard/crm_recent_events.dart';
import 'crm_dashboard/crm_welcome_header.dart';
import 'dashboard_devices_section.dart';
import 'dashboard_kpi_row.dart';
import 'dashboard_skeleton.dart';


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
  late final DashboardPollingController _controller;
  String? _expandedDeviceId;

  @override
  void initState() {
    super.initState();
    _controller = DashboardPollingController(
      repo: widget.repository ?? CrmRepository(),
      monitoringRepo: MonitoringRepository(),
      alertsRepo: AlertsRepository(),
      cacheService: DashboardCacheService(),
      lifecycleService: AppLifecycleService(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.start();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void refreshAll() => _controller.forceRefresh();

  void _onDeviceToggle(String id) => setState(() =>
      _expandedDeviceId = _expandedDeviceId == id ? null : id);

  void _onDeviceViewDetail(String id) =>
      Navigator.of(context).pushNamed('/device/$id');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: ValueListenableBuilder<SectionSnapshot<CrmDashboardResponse>>(
        valueListenable: _controller.dashboardSnapshot,
        builder: (context, snapshot, _) {
          if (snapshot.loading && snapshot.data == null) {
            return const DashboardSkeleton();
          }
          if (snapshot.error != null && snapshot.data == null) {
            return Padding(
              padding: EdgeInsets.only(top: DesignSpacing.xl),
              child: Center(child: Text('Could not load dashboard. Tap to retry.',
                  textAlign: TextAlign.center)),
            );
          }
          final data = snapshot.data;
          if (data == null) return const Center(child: Text('Loading devices...'));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrmWelcomeHeader(data: data),
              SizedBox(height: DesignSpacing.xl),
              DashboardKpiRow(kpis: data.kpis),
              SizedBox(height: DesignSpacing.xl),
              ValueListenableBuilder<SectionSnapshot<List<CrmDeviceSummary>>>(
                valueListenable: _controller.devicesSnapshot,
                builder: (context2, devSnap, _) {
                  return DashboardDevicesSection(
                    devices: devSnap.data ?? [],
                    expandedDeviceId: _expandedDeviceId,
                    onToggle: _onDeviceToggle,
                    onViewDetail: _onDeviceViewDetail,
                    isLoading: devSnap.loading && devSnap.data == null,
                  );
                },
              ),
              SizedBox(height: DesignSpacing.xl),
              const SectionHeader(title: 'Inteligencia Artificial'),
              SizedBox(height: DesignSpacing.md),
              ValueListenableBuilder<SectionSnapshot<List<UnifiedAlertItem>>>(
                valueListenable: _controller.mlWarningsSnapshot,
                builder: (context, warnSnap, _) {
                  final warnings = warnSnap.data ?? const [];
                  return ValueListenableBuilder<SectionSnapshot<List<PredictionViewModel>>>(
                    valueListenable: _controller.predictionsSnapshot,
                    builder: (context2, predSnap, _) => CrmMlPredictionsPanel(
                      warnings: warnings,
                      predictions: predSnap.data ?? const [],
                    ),
                  );
                },
              ),
              SizedBox(height: DesignSpacing.xl),
              const SectionHeader(title: 'Alertas Activas'),
              SizedBox(height: DesignSpacing.md),
              CrmAlertQueue(items: data.alertQueue),
              SizedBox(height: DesignSpacing.xl),
              const SectionHeader(title: 'Actividad Reciente'),
              SizedBox(height: DesignSpacing.md),
              CrmRecentEvents(items: data.recentEvents),
              SizedBox(height: DesignSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}
