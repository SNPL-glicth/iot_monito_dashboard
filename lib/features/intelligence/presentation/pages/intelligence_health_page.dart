import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../devices/data/models/ml_features_model.dart';
import '../../../devices/data/ml_features_service.dart';
import '../../data/intelligence_models.dart';
import '../../data/intelligence_repository.dart';
import '../widgets/intelligence_health_widgets.dart';
import 'intelligence_health/loading_state_widget.dart';
import 'intelligence_health/error_state_widget.dart';
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
  late Future<MlDiagnosticViewModel> _future;
  MLFeaturesModel? _mlFeatures;
  Timer? _mlFeaturesTimer;

  @override
  void initState() {
    super.initState();
    _repo = IntelligenceRepository(ApiClient());
    _mlFeaturesService = MLFeaturesService(baseUrl: 'http://127.0.0.1:8002');
    _future = _repo.fetchMlDiagnostic();
    _loadMLFeatures();
    
    // Actualizar ML Features cada 10 segundos
    _mlFeaturesTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadMLFeatures();
    });
  }

  @override
  void dispose() {
    _mlFeaturesTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMLFeatures() async {
    try {
      final features = await _mlFeaturesService.getLatestFeatures(1);
      if (mounted) {
        setState(() {
          _mlFeatures = features;
        });
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
      ),
      body: FutureBuilder<MlDiagnosticViewModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingStateWidget();
          }

          if (snapshot.hasError) {
            return ErrorStateWidget(errorMessage: snapshot.error.toString());
          }

          final data = snapshot.data;
          if (data == null) {
            return IntelligenceHealthWidgets.emptyState();
          }

          return IntelligenceHealthBodyWidget(data: data, mlFeatures: _mlFeatures);
        },
      ),
    );
  }
}
