import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/presentation/widgets/app_loading_widget.dart';
import '../../../devices/data/models/ml_features_model.dart';
import '../../../devices/data/ml_features_service.dart';
import '../../data/intelligence_models.dart';
import '../../data/intelligence_repository.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../widgets/intelligence_health_widgets.dart';
import 'intelligence_health/orchestrator_error_widget.dart';
import 'intelligence_health/intelligence_health_body_widget.dart';

/// Página de Estado del Modelo ML
/// 
/// Muestra diagnóstico completo del modelo de Machine Learning:
/// - Estado de salud (healthy/degraded/critical/unknown)
/// - Métricas de error (MAE, RMSE, MAPE)
/// - Calidad de predicciones por confianza
/// - Precisión por umbral
/// - Actividad del modelo
/// - Detección de anomalías
/// - Recomendaciones y advertencias
/// 
/// ISO 27001: Solo expone métricas agregadas, no datos sensibles.
/// Esta vista NO muestra predicciones individuales.
class IntelligenceHealthPage extends StatefulWidget {
  const IntelligenceHealthPage({super.key});

  @override
  State<IntelligenceHealthPage> createState() => _IntelligenceHealthPageState();
}

class _IntelligenceHealthPageState extends State<IntelligenceHealthPage> {
  late final IntelligenceRepository _repo;
  late final MLFeaturesService _mlFeaturesService;

  bool _loading = true;
  MlDiagnosticViewModel? _data;
  MLFeaturesModel? _mlFeatures;
  String? _error;
  DateTime? _lastKnownPing;
  DateTime? _lastValidTimestamp;
  Timer? _mlFeaturesTimer;
  StreamSubscription<void>? _lifecyclePauseSub;
  StreamSubscription<void>? _lifecycleResumeSub;

  @override
  void initState() {
    super.initState();
    _repo = IntelligenceRepository(ApiClient());
    _mlFeaturesService = MLFeaturesService(baseUrl: 'http://127.0.0.1:8002');
    _loadDiagnostic();
    _loadMLFeatures();
    _startMLFeaturesPolling();

    _lifecyclePauseSub = AppLifecycleService().onAppPaused.listen((_) {
      _mlFeaturesTimer?.cancel();
    });
    _lifecycleResumeSub = AppLifecycleService().onAppResumed.listen((_) {
      _startMLFeaturesPolling();
      _loadMLFeatures();
    });
  }

  void _startMLFeaturesPolling() {
    _mlFeaturesTimer?.cancel();
    _mlFeaturesTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadMLFeatures();
    });
  }

  @override
  void dispose() {
    _mlFeaturesTimer?.cancel();
    _lifecyclePauseSub?.cancel();
    _lifecycleResumeSub?.cancel();
    super.dispose();
  }

  Future<void> _loadDiagnostic() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repo.fetchMlDiagnostic();
      _lastKnownPing = DateTime.now();
      _lastValidTimestamp = DateTime.tryParse(data.timestamp) ?? DateTime.now();
      if (mounted) {
        setState(() {
          _data = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMLFeatures() async {
    try {
      final features = await _mlFeaturesService.getLatestFeatures(1);
      if (mounted) {
        setState(() => _mlFeatures = features);
      }
    } catch (e) {
      debugPrint('Failed to load ML features: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del Modelo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiagnostic,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _data == null) {
      return const AppLoadingWidget(message: 'Cargando diagnóstico del modelo...');
    }

    if (_error != null && _data == null) {
      return OrchestratorErrorWidget(
        errorMessage: _error!,
        lastKnownPing: _lastKnownPing,
        lastValidTimestamp: _lastValidTimestamp,
        onRetry: _loadDiagnostic,
      );
    }

    if (_data == null) {
      return IntelligenceHealthWidgets.emptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadDiagnostic,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DashboardColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DashboardColors.error.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: DashboardColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Datos desactualizados. Error: $_error',
                      style: DashboardTextStyles.sensorMeta.copyWith(color: DashboardColors.error),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadDiagnostic,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          IntelligenceHealthBodyWidget(data: _data!, mlFeatures: _mlFeatures),
        ],
      ),
    );
  }
}
