/// Servicio de snapshots de alertas para gráficas congeladas.
/// 
/// FASE 1: Las gráficas de detalle de alerta NO deben ser streams en tiempo real.
/// Cada alerta tiene su propio snapshot de datos congelado.
/// 
/// Características:
/// - Snapshot inmutable de datos al momento de la alerta
/// - Ventana de contexto configurable (antes/después del evento)
/// - Sin polling ni refresh automático
/// - LTTB NO se aplica en snapshots congelados
library;

import 'package:flutter/foundation.dart' show debugPrint;

import 'models/alert_snapshot_models.dart';

/// Servicio singleton para gestionar snapshots de alertas
class AlertSnapshotService {
  // Singleton
  static final AlertSnapshotService _instance = AlertSnapshotService._internal();
  factory AlertSnapshotService() => _instance;
  AlertSnapshotService._internal();

  // Cache de snapshots por alertId
  final Map<String, AlertSnapshot> _snapshotCache = {};
  
  // Configuración de ventana de contexto
  static const Duration defaultContextBefore = Duration(minutes: 30);
  static const Duration defaultContextAfter = Duration(minutes: 5);
  static const int maxPointsInSnapshot = 100; // Sin LTTB, limitamos puntos

  /// Obtiene un snapshot cacheado
  /// FIX: No retornar snapshots vacíos del cache
  AlertSnapshot? getCachedSnapshot(String alertId) {
    final cached = _snapshotCache[alertId];
    if (cached != null && cached.points.isEmpty) {
      debugPrint('[SnapshotService] Ignoring empty cached snapshot for $alertId');
      _snapshotCache.remove(alertId);
      return null;
    }
    return cached;
  }
  
  /// Limpia el cache de un snapshot específico
  void clearCachedSnapshot(String alertId) {
    _snapshotCache.remove(alertId);
  }
  
  /// Limpia todo el cache
  void clearAllCache() {
    _snapshotCache.clear();
  }

  /// Guarda un snapshot en cache
  /// FIX: No cachear snapshots vacíos
  void cacheSnapshot(AlertSnapshot snapshot) {
    if (snapshot.points.isEmpty) {
      debugPrint('[SnapshotService] NOT caching empty snapshot for ${snapshot.alertId}');
      return;
    }
    _snapshotCache[snapshot.alertId] = snapshot;
    _pruneCache();
  }

  /// Crea un snapshot desde datos de trading series
  AlertSnapshot createSnapshotFromTradingSeries({
    required String alertId,
    required String sensorId,
    required String sensorName,
    required String deviceName,
    required String unit,
    required String severity,
    required double triggeredValue,
    required DateTime triggeredAt,
    required List<Map<String, dynamic>> tradingSeries,
    double? thresholdMin,
    double? thresholdMax,
    double? warningMin,
    double? warningMax,
    String? message,
  }) {
    debugPrint('[SnapshotService] Creating snapshot from ${tradingSeries.length} trading points');
    debugPrint('[SnapshotService] TriggeredAt: $triggeredAt (${triggeredAt.timeZoneName})');
    
    // Filtrar puntos dentro de la ventana de contexto
    final windowStart = triggeredAt.subtract(defaultContextBefore);
    final windowEnd = triggeredAt.add(defaultContextAfter);
    
    debugPrint('[SnapshotService] Window: $windowStart to $windowEnd');

    final filteredPoints = <AlertSnapshotPoint>[];
    int skippedNull = 0;
    int skippedParse = 0;
    int skippedWindow = 0;
    
    for (final p in tradingSeries) {
      final tsStr = p['timestamp'] as String?;
      if (tsStr == null) {
        skippedNull++;
        continue;
      }
      
      final ts = DateTime.tryParse(tsStr);
      if (ts == null) {
        skippedParse++;
        continue;
      }
      
      // FIX: Convertir a local para comparación consistente
      final tsLocal = ts.toLocal();
      final triggeredAtLocal = triggeredAt.toLocal();
      final windowStartLocal = windowStart.toLocal();
      final windowEndLocal = windowEnd.toLocal();
      
      // Solo incluir puntos dentro de la ventana
      if (tsLocal.isBefore(windowStartLocal) || tsLocal.isAfter(windowEndLocal)) {
        skippedWindow++;
        continue;
      }
      
      final value = (p['value'] as num?)?.toDouble() ?? 0.0;
      final state = p['state'] as String? ?? 'NORMAL';
      
      // Marcar el punto que disparó la alerta (dentro de 1 segundo)
      final isTrigger = tsLocal.difference(triggeredAtLocal).inSeconds.abs() <= 1 ||
          (value - triggeredValue).abs() < 0.001;
      
      filteredPoints.add(AlertSnapshotPoint(
        timestamp: tsLocal,
        value: value,
        isAlertTrigger: isTrigger,
        state: state,
      ));
    }
    
    debugPrint('[SnapshotService] Filtered: ${filteredPoints.length} points (skipped: null=$skippedNull, parse=$skippedParse, window=$skippedWindow)');
    
    // FIX: Si no hay puntos después del filtro, incluir TODOS los puntos disponibles
    if (filteredPoints.isEmpty && tradingSeries.isNotEmpty) {
      debugPrint('[SnapshotService] WARNING: Window filter removed all points! Including all available points.');
      
      // Mostrar sample de timestamps para diagnóstico
      if (tradingSeries.isNotEmpty) {
        final firstTs = tradingSeries.first['timestamp'];
        final lastTs = tradingSeries.last['timestamp'];
        debugPrint('[SnapshotService] Data range: $firstTs to $lastTs');
      }
      
      // Incluir todos los puntos sin filtro de ventana
      for (final p in tradingSeries) {
        final tsStr = p['timestamp'] as String?;
        if (tsStr == null) continue;
        
        final ts = DateTime.tryParse(tsStr);
        if (ts == null) continue;
        
        final value = (p['value'] as num?)?.toDouble() ?? 0.0;
        final state = p['state'] as String? ?? 'NORMAL';
        
        filteredPoints.add(AlertSnapshotPoint(
          timestamp: ts.toLocal(),
          value: value,
          isAlertTrigger: false,
          state: state,
        ));
      }
      
      // Marcar el punto más cercano al triggeredValue como trigger
      if (filteredPoints.isNotEmpty) {
        int closestIdx = 0;
        double closestDiff = double.infinity;
        for (int i = 0; i < filteredPoints.length; i++) {
          final diff = (filteredPoints[i].value - triggeredValue).abs();
          if (diff < closestDiff) {
            closestDiff = diff;
            closestIdx = i;
          }
        }
        // Recrear el punto como trigger
        final p = filteredPoints[closestIdx];
        filteredPoints[closestIdx] = AlertSnapshotPoint(
          timestamp: p.timestamp,
          value: p.value,
          isAlertTrigger: true,
          state: p.state,
        );
      }
      
      debugPrint('[SnapshotService] Included all ${filteredPoints.length} points without window filter');
    }

    // Ordenar por timestamp
    filteredPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // FIX FINAL: Si aún no hay puntos, crear al menos el punto trigger
    if (filteredPoints.isEmpty) {
      debugPrint('[SnapshotService] FALLBACK: Creating single trigger point');
      filteredPoints.add(AlertSnapshotPoint(
        timestamp: triggeredAt.toLocal(),
        value: triggeredValue,
        isAlertTrigger: true,
        state: severity.toUpperCase(),
      ));
    }

    // Limitar puntos SIN aplicar LTTB (datos congelados deben ser exactos)
    final limitedPoints = filteredPoints.length > maxPointsInSnapshot
        ? _selectRepresentativePoints(filteredPoints, maxPointsInSnapshot)
        : filteredPoints;
    
    debugPrint('[SnapshotService] Final snapshot has ${limitedPoints.length} points');

    final snapshot = AlertSnapshot(
      alertId: alertId,
      sensorId: sensorId,
      sensorName: sensorName,
      deviceName: deviceName,
      unit: unit,
      severity: severity,
      triggeredValue: triggeredValue,
      triggeredAt: triggeredAt,
      points: limitedPoints,
      thresholdMin: thresholdMin,
      thresholdMax: thresholdMax,
      warningMin: warningMin,
      warningMax: warningMax,
      message: message,
    );

    // Cachear automáticamente
    cacheSnapshot(snapshot);

    return snapshot;
  }

  /// Selecciona puntos representativos sin LTTB
  /// Mantiene: primer punto, último punto, punto trigger, y distribuye el resto
  List<AlertSnapshotPoint> _selectRepresentativePoints(
    List<AlertSnapshotPoint> points,
    int maxPoints,
  ) {
    if (points.length <= maxPoints) return points;

    final result = <AlertSnapshotPoint>[];
    
    // Siempre incluir primer y último punto
    result.add(points.first);
    
    // Encontrar y reservar el punto trigger
    final triggerIndex = points.indexWhere((p) => p.isAlertTrigger);
    
    // Calcular step para distribución uniforme
    final step = (points.length - 2) / (maxPoints - 2);
    
    for (var i = 1; i < maxPoints - 1; i++) {
      final index = (i * step).round().clamp(1, points.length - 2);
      
      // Si estamos cerca del trigger, incluirlo
      if (triggerIndex >= 0 && (index - triggerIndex).abs() <= 1) {
        if (!result.any((p) => p.isAlertTrigger)) {
          result.add(points[triggerIndex]);
          continue;
        }
      }
      
      // Evitar duplicados
      if (!result.contains(points[index])) {
        result.add(points[index]);
      }
    }
    
    // Siempre incluir último punto
    if (!result.contains(points.last)) {
      result.add(points.last);
    }
    
    // Asegurar que el trigger está incluido
    if (triggerIndex >= 0 && !result.any((p) => p.isAlertTrigger)) {
      result.add(points[triggerIndex]);
    }
    
    // Reordenar por timestamp
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return result;
  }

  /// Limpia cache si excede el límite
  void _pruneCache() {
    const maxCacheSize = 20;
    if (_snapshotCache.length <= maxCacheSize) return;
    
    // Eliminar los más antiguos (por triggeredAt)
    final entries = _snapshotCache.entries.toList()
      ..sort((a, b) => a.value.triggeredAt.compareTo(b.value.triggeredAt));
    
    final toRemove = entries.length - maxCacheSize;
    for (var i = 0; i < toRemove; i++) {
      _snapshotCache.remove(entries[i].key);
    }
  }

  /// Invalida un snapshot específico
  void invalidateSnapshot(String alertId) {
    _snapshotCache.remove(alertId);
  }

  /// Limpia todo el cache
  void clearCache() {
    _snapshotCache.clear();
  }

  /// Debug: obtiene estadísticas del cache
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _snapshotCache.length,
      'alertIds': _snapshotCache.keys.toList(),
    };
  }
}
