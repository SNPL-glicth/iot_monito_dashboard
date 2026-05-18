import 'dart:collection';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

import 'chart_downsampling.dart';

/// Procesador de datos de gráficas con cache y compute() para isolates.
/// 
/// PERF: Mueve procesamiento pesado fuera del UI thread.
/// - LTTB downsampling en isolate
/// - Cache LRU de puntos procesados
/// - Límite de memoria para series de tiempo
class ChartDataProcessor {
  // Singleton
  static final ChartDataProcessor _instance = ChartDataProcessor._internal();
  factory ChartDataProcessor() => _instance;
  ChartDataProcessor._internal();

  /// Cache LRU de puntos procesados por clave (sensorId|range|hash)
  static final LinkedHashMap<String, _CachedChartData> _cache = LinkedHashMap();
  
  /// FIX FASE 2.3: Aumentar límite de entradas de 30 a 50 para soportar más sensores
  static const int _maxCacheEntries = 50;
  
  /// Límite de puntos en memoria por serie (evita OOM)
  static const int _maxPointsInMemory = 500;
  
  /// FIX FASE 2.3: Aumentar TTL de 60s a 300s (5 minutos) para reducir recálculos
  /// Las gráficas no cambian tan frecuentemente, 5 min es razonable
  static const int _cacheTtlSeconds = 300;

  /// Procesa datos crudos para gráfica con cache y downsampling.
  /// 
  /// [key] - Clave única para cache (ej: "sensor123|1h")
  /// [rawData] - Lista de (timestamp, value) crudos
  /// [targetPoints] - Número máximo de puntos después de downsampling
  /// 
  /// Retorna lista de FlSpot lista para renderizar.
  Future<List<FlSpot>> processChartData({
    required String key,
    required List<({DateTime timestamp, double value})> rawData,
    int targetPoints = kMaxChartPoints,
  }) async {
    // Verificar cache
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) {
      // Mover al final (LRU)
      _cache.remove(key);
      _cache[key] = cached;
      return cached.spots;
    }

    // Procesar en isolate si hay muchos datos
    List<FlSpot> spots;
    if (rawData.length > 100) {
      spots = await compute(_processInIsolate, _ProcessParams(
        data: rawData,
        targetPoints: targetPoints,
      ));
    } else {
      spots = _processSync(rawData, targetPoints);
    }

    // Guardar en cache
    _cache[key] = _CachedChartData(spots: spots);
    _pruneCache();

    return spots;
  }

  /// Procesa datos de candlestick con estados (NORMAL, WARNING, ALERT)
  Future<CandlestickProcessedData> processCandlestickData({
    required String key,
    required List<CandlestickRawPoint> rawData,
    int targetPoints = kMaxChartPoints,
  }) async {
    final cacheKey = 'candle_$key';
    
    // Verificar cache específico de candlestick
    final cached = _candlestickCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      _candlestickCache.remove(cacheKey);
      _candlestickCache[cacheKey] = cached;
      return cached.data;
    }

    // Procesar en isolate
    CandlestickProcessedData result;
    if (rawData.length > 100) {
      result = await compute(_processCandlestickInIsolate, _CandlestickParams(
        data: rawData,
        targetPoints: targetPoints,
      ));
    } else {
      result = _processCandlestickSync(rawData, targetPoints);
    }

    // Guardar en cache
    _candlestickCache[cacheKey] = _CachedCandlestickData(data: result);
    _pruneCandlestickCache();

    return result;
  }

  /// Invalida cache para un sensor específico
  void invalidateCache(String sensorId) {
    _cache.removeWhere((key, _) => key.startsWith(sensorId));
    _candlestickCache.removeWhere((key, _) => key.contains(sensorId));
  }

  /// Limpia todo el cache
  void clearCache() {
    _cache.clear();
    _candlestickCache.clear();
  }

  // Cache específico para candlestick
  static final LinkedHashMap<String, _CachedCandlestickData> _candlestickCache = LinkedHashMap();

  void _pruneCache() {
    while (_cache.length > _maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  void _pruneCandlestickCache() {
    while (_candlestickCache.length > _maxCacheEntries) {
      _candlestickCache.remove(_candlestickCache.keys.first);
    }
  }

  /// Procesamiento síncrono para datasets pequeños
  static List<FlSpot> _processSync(
    List<({DateTime timestamp, double value})> rawData,
    int targetPoints,
  ) {
    if (rawData.isEmpty) return [];

    // Ordenar por timestamp
    final sorted = List.of(rawData)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Limitar puntos en memoria
    final limited = sorted.length > _maxPointsInMemory
        ? sorted.sublist(sorted.length - _maxPointsInMemory)
        : sorted;

    // Convertir a DataPoint para LTTB
    final dataPoints = limited.asMap().entries.map((e) {
      return DataPoint(e.key.toDouble(), e.value.value);
    }).toList();

    // Aplicar downsampling si necesario
    final downsampled = dataPoints.length > targetPoints
        ? lttbDownsample(dataPoints, targetPoints)
        : dataPoints;

    // Convertir a FlSpot
    return downsampled.map((p) => FlSpot(p.x, p.y)).toList();
  }

  /// Procesamiento síncrono de candlestick
  static CandlestickProcessedData _processCandlestickSync(
    List<CandlestickRawPoint> rawData,
    int targetPoints,
  ) {
    if (rawData.isEmpty) {
      return const CandlestickProcessedData(
        mainSpots: [],
        alertSpots: [],
        warningSpots: [],
        highlightSpots: [],
        minT: 0,
        maxT: 0,
        minV: 0,
        maxV: 0,
      );
    }

    // Ordenar por timestamp
    final sorted = List.of(rawData)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Limitar puntos
    final limited = sorted.length > _maxPointsInMemory
        ? sorted.sublist(sorted.length - _maxPointsInMemory)
        : sorted;

    // Crear spots
    final mainSpots = <FlSpot>[];
    final alertSpots = <FlSpot>[];
    final warningSpots = <FlSpot>[];
    final highlightSpots = <FlSpot>[];

    double minT = double.infinity;
    double maxT = double.negativeInfinity;
    double minV = double.infinity;
    double maxV = double.negativeInfinity;

    for (final p in limited) {
      final x = p.timestamp.millisecondsSinceEpoch.toDouble();
      final spot = FlSpot(x, p.value);
      
      mainSpots.add(spot);

      if (x < minT) minT = x;
      if (x > maxT) maxT = x;
      if (p.value < minV) minV = p.value;
      if (p.value > maxV) maxV = p.value;

      if (p.isAlert) {
        alertSpots.add(spot);
      } else if (p.isWarning) {
        warningSpots.add(spot);
      }

      if (p.isHighlighted) {
        highlightSpots.add(spot);
      }
    }

    return CandlestickProcessedData(
      mainSpots: mainSpots,
      alertSpots: alertSpots,
      warningSpots: warningSpots,
      highlightSpots: highlightSpots,
      minT: minT,
      maxT: maxT,
      minV: minV,
      maxV: maxV,
    );
  }
}

/// Función top-level para compute() - procesa datos en isolate
List<FlSpot> _processInIsolate(_ProcessParams params) {
  return ChartDataProcessor._processSync(params.data, params.targetPoints);
}

/// Función top-level para compute() - procesa candlestick en isolate
CandlestickProcessedData _processCandlestickInIsolate(_CandlestickParams params) {
  return ChartDataProcessor._processCandlestickSync(params.data, params.targetPoints);
}

/// Parámetros para isolate
class _ProcessParams {
  const _ProcessParams({required this.data, required this.targetPoints});
  final List<({DateTime timestamp, double value})> data;
  final int targetPoints;
}

class _CandlestickParams {
  const _CandlestickParams({required this.data, required this.targetPoints});
  final List<CandlestickRawPoint> data;
  final int targetPoints;
}

/// Datos cacheados con TTL
class _CachedChartData {
  _CachedChartData({required this.spots})
      : createdAt = DateTime.now();
  
  final List<FlSpot> spots;
  final DateTime createdAt;
  
  bool get isExpired => DateTime.now().difference(createdAt).inSeconds > ChartDataProcessor._cacheTtlSeconds;
}

class _CachedCandlestickData {
  _CachedCandlestickData({required this.data})
      : createdAt = DateTime.now();
  
  final CandlestickProcessedData data;
  final DateTime createdAt;
  
  bool get isExpired => DateTime.now().difference(createdAt).inSeconds > ChartDataProcessor._cacheTtlSeconds;
}

/// Punto crudo para candlestick
class CandlestickRawPoint {
  const CandlestickRawPoint({
    required this.timestamp,
    required this.value,
    this.isAlert = false,
    this.isWarning = false,
    this.isHighlighted = false,
  });

  final DateTime timestamp;
  final double value;
  final bool isAlert;
  final bool isWarning;
  final bool isHighlighted;
}

/// Datos procesados de candlestick
class CandlestickProcessedData {
  const CandlestickProcessedData({
    required this.mainSpots,
    required this.alertSpots,
    required this.warningSpots,
    required this.highlightSpots,
    required this.minT,
    required this.maxT,
    required this.minV,
    required this.maxV,
  });

  final List<FlSpot> mainSpots;
  final List<FlSpot> alertSpots;
  final List<FlSpot> warningSpots;
  final List<FlSpot> highlightSpots;
  final double minT;
  final double maxT;
  final double minV;
  final double maxV;

  bool get isEmpty => mainSpots.isEmpty;
}
