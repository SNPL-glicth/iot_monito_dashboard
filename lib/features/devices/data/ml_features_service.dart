import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import 'models/ml_features_model.dart';

/// ML Features Service - Consumes ML features from telemetry API.
/// 
/// FASE 2.6: This service fetches ML features that are ALWAYS produced,
/// making the ML observable and explainable in the UI.
class MLFeaturesService {
  MLFeaturesService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  final String baseUrl;
  final Duration timeout;
  final ApiClient _apiClient;

  /// Get latest ML features for a sensor.
  /// 
  /// Returns null if no features are available.
  Future<MLFeaturesModel?> getLatestFeatures(int sensorId) async {
    try {
      final json = await _apiClient.getJson(
        '/telemetry/ml-features/latest/$sensorId',
        baseUrl: baseUrl,
      );
      final featuresJson = json['features'];
      if (featuresJson == null) {
        return null;
      }
      return MLFeaturesModel.fromJson(featuresJson as Map<String, dynamic>);
    } catch (e) {
      // Log error but don't throw - ML features are optional
      debugPrint('[MLFeaturesService] Error fetching latest features: $e');
      return null;
    }
  }

  /// Get ML features history for a sensor.
  /// 
  /// [from] and [to] are ISO timestamps.
  /// [limit] is the maximum number of records to return.
  Future<List<MLFeaturesModel>> getFeaturesHistory({
    required int sensorId,
    String? from,
    String? to,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final path = '/telemetry/ml-features/history/$sensorId';
      final queryString = queryParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
      final fullPath = '$path?$queryString';

      final json = await _apiClient.getJson(
        fullPath,
        baseUrl: baseUrl,
      );
      final featuresJson = json['features'] as List<dynamic>? ?? [];

      return featuresJson
          .map((f) => MLFeaturesModel.fromJson(f as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[MLFeaturesService] Error fetching features history: $e');
      return [];
    }
  }

  /// Get latest ML features for multiple sensors.
  /// 
  /// Returns a map of sensor_id -> MLFeaturesModel.
  Future<Map<int, MLFeaturesModel>> getLatestFeaturesForSensors(
    List<int> sensorIds,
  ) async {
    if (sensorIds.isEmpty) return {};

    try {
      final json = await _apiClient.postJsonAndDecode(
        '/telemetry/ml-features/latest/batch',
        {'sensor_ids': sensorIds},
        baseUrl: baseUrl,
      );
      final featuresJson = json['features'] as Map<String, dynamic>? ?? {};

      final result = <int, MLFeaturesModel>{};
      featuresJson.forEach((key, value) {
        final sensorId = int.tryParse(key);
        if (sensorId != null && value != null) {
          result[sensorId] = MLFeaturesModel.fromJson(value as Map<String, dynamic>);
        }
      });

      return result;
    } catch (e) {
      debugPrint('[MLFeaturesService] Error fetching batch features: $e');
      return {};
    }
  }

  /// Stream ML features for a sensor with polling.
  /// 
  /// Polls the API every [interval] and emits new features.
  Stream<MLFeaturesModel> streamFeatures({
    required int sensorId,
    Duration interval = const Duration(seconds: 1),
  }) async* {
    MLFeaturesModel? lastFeatures;
    
    while (true) {
      await Future.delayed(interval);
      
      final features = await getLatestFeatures(sensorId);
      
      // Only emit if features changed
      if (features != null && 
          (lastFeatures == null || features.timestamp != lastFeatures.timestamp)) {
        lastFeatures = features;
        yield features;
      }
    }
  }
}

/// Provider for MLFeaturesService singleton.
/// 
/// Usage:
/// ```dart
/// final service = MLFeaturesServiceProvider.instance;
/// final features = await service.getLatestFeatures(sensorId);
/// ```
class MLFeaturesServiceProvider {
  MLFeaturesServiceProvider._();
  
  static MLFeaturesService? _instance;
  static String _baseUrl = 'http://localhost:3002';
  
  /// Configure the base URL for the telemetry API.
  static void configure({required String baseUrl}) {
    _baseUrl = baseUrl;
    _instance = null; // Reset instance to use new URL
  }
  
  /// Get the singleton instance.
  static MLFeaturesService get instance {
    _instance ??= MLFeaturesService(baseUrl: _baseUrl);
    return _instance!;
  }
}

/// Extension to add ML features to a list of data points.
extension MLFeaturesExtension on List<dynamic> {
  /// Enrich data points with ML features.
  /// 
  /// [featuresMap] is a map of timestamp -> MLFeaturesModel.
  /// Points are matched by timestamp (within 1 second tolerance).
  List<T> enrichWithMLFeatures<T>(
    Map<double, MLFeaturesModel> featuresMap,
    T Function(dynamic point, MLFeaturesModel? features) mapper,
  ) {
    return map((point) {
      // Try to find matching features by timestamp
      final pointTs = (point.timestamp as DateTime).millisecondsSinceEpoch / 1000;
      
      MLFeaturesModel? matchingFeatures;
      for (final entry in featuresMap.entries) {
        if ((entry.key - pointTs).abs() < 1.0) {
          matchingFeatures = entry.value;
          break;
        }
      }
      
      return mapper(point, matchingFeatures);
    }).toList();
  }
}
