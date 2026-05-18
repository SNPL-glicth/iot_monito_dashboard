import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import 'intelligence_models.dart';

/// Repositorio para el "Centro de Inteligencia" (predicciones + salud ML + decisiones).
class IntelligenceRepository {
  IntelligenceRepository(this._client);

  final ApiClient _client;
  
  // Cliente HTTP para telemetría (separado del backend NestJS)
  static final http.Client _telemetryClient = http.Client();

  /// Predicciones resumidas para la vista de "Predicciones".
  Future<List<PredictionSummaryViewModel>> fetchLatestPredictions() async {
    // Backend actual: GET /intelligence/predictions?limit=50
    final list = await _client.getList('/intelligence/predictions?limit=50');
    return list
        .whereType<Map>()
        .map((e) => PredictionSummaryViewModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// Estado general del sistema ML.
  Future<MlHealthViewModel> fetchMlHealth() async {
    // Espera que el backend exponga GET /monitoring/ml-health
    final json = await _client.getJson('/monitoring/ml-health');
    return MlHealthViewModel.fromJson(json);
  }

  /// Decisiones consolidadas del Decision Orchestrator Worker.
  Future<List<DecisionActionViewModel>> fetchDecisions({
    String? status,
    String? severity,
    int limit = 50,
  }) async {
    String url = '/intelligence/decisions?limit=$limit';
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }
    if (severity != null && severity.isNotEmpty) {
      url += '&severity=$severity';
    }

    final json = await _client.getJson(url);
    final decisionsRaw = json['decisions'];
    if (decisionsRaw is List) {
      return decisionsRaw
          .whereType<Map>()
          .map((e) => DecisionActionViewModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  /// Actualiza el estado de una decisión.
  Future<DecisionActionViewModel> updateDecisionStatus(
    String decisionId,
    String newStatus,
  ) async {
    final json = await _client.patchJsonAndDecode(
      '/intelligence/decisions/$decisionId/status',
      {'status': newStatus},
    );
    return DecisionActionViewModel.fromJson(json);
  }

  /// Diagnóstico detallado del modelo ML.
  /// 
  /// Endpoint: GET /diagnostics/ml/model-status (servidor de telemetría)
  /// 
  /// Proporciona métricas de salud, error, calidad y actividad del modelo.
  /// ISO 27001: Solo expone métricas agregadas, no datos sensibles.
  /// 
  /// NOTA: Este endpoint está en el servidor de telemetría (puerto 8099),
  /// no en el backend NestJS, para evitar sobrecarga.
  Future<MlDiagnosticViewModel> fetchMlDiagnostic() async {
    final uri = Uri.parse('${ApiConfig.telemetryUrl}/diagnostics/ml/model-status');
    
    final response = await _telemetryClient.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('La respuesta no es un objeto JSON');
      }
      return MlDiagnosticViewModel.fromJson(decoded);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        method: 'GET',
        path: '/diagnostics/ml/model-status',
        body: response.body,
      );
    }
  }

  /// Insights del Decision Orchestrator.
  /// 
  /// Endpoint: GET /diagnostics/orchestrator/insights (servidor de telemetría)
  /// 
  /// Proporciona información enriquecida sobre:
  /// - Análisis de cambios (ruido, micro-variación, cambio real, degradación)
  /// - Análisis de spikes (tipo, duración, frecuencia, contexto)
  /// - Tareas identificadas para el ML
  /// - Señales débiles detectadas
  /// - Contexto narrativo de la situación
  /// 
  /// ISO 27001: Solo expone métricas agregadas, no datos sensibles.
  Future<OrchestratorInsightsViewModel> fetchOrchestratorInsights() async {
    final uri = Uri.parse('${ApiConfig.telemetryUrl}/diagnostics/orchestrator/insights');
    
    final response = await _telemetryClient.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('La respuesta no es un objeto JSON');
      }
      return OrchestratorInsightsViewModel.fromJson(decoded);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        method: 'GET',
        path: '/diagnostics/orchestrator/insights',
        body: response.body,
      );
    }
  }
}
