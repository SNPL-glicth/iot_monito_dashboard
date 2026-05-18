/// Algoritmo LTTB (Largest Triangle Three Buckets) para downsampling de gráficas.
///
/// Reduce el número de puntos manteniendo la forma visual de la serie.
/// Ideal para gráficas con muchos puntos que causan freeze en Flutter.
library;

import 'dart:math' as math;

/// Punto de datos para downsampling.
class DataPoint {
  const DataPoint(this.x, this.y);
  final double x;
  final double y;
}

/// Aplica el algoritmo LTTB para reducir una serie de puntos.
///
/// [data] - Lista de puntos originales
/// [threshold] - Número máximo de puntos en el resultado
///
/// Retorna una lista reducida que preserva la forma visual.
List<DataPoint> lttbDownsample(List<DataPoint> data, int threshold) {
  if (data.length <= threshold || threshold < 3) {
    return List.from(data);
  }

  final sampled = <DataPoint>[];
  
  // Siempre incluir el primer punto
  sampled.add(data.first);

  // Tamaño de cada bucket (excluyendo primer y último punto)
  final bucketSize = (data.length - 2) / (threshold - 2);

  int a = 0; // Índice del punto que se selecciono anteriormente 

  for (int i = 0; i < threshold - 2; i++) {
    // Calcular rango del bucket actual
    final bucketStart = ((i + 1) * bucketSize).floor() + 1;
    final bucketEnd = ((i + 2) * bucketSize).floor() + 1;
    final actualEnd = math.min(bucketEnd, data.length - 1);

    // Calcular punto promedio del siguiente bucket para que de el triangulo 
    final nextBucketStart = actualEnd;
    final nextBucketEnd = math.min(((i + 3) * bucketSize).floor() + 1, data.length);
    
    double avgX = 0;
    double avgY = 0;
    int avgCount = 0;
    
    for (int j = nextBucketStart; j < nextBucketEnd; j++) {
      avgX += data[j].x;
      avgY += data[j].y;
      avgCount++;
    }
    
    if (avgCount > 0) {
      avgX /= avgCount;
      avgY /= avgCount;
    } else {
      // Fallback al último punto
      avgX = data.last.x;
      avgY = data.last.y;
    }

    // Encontrar el punto en el bucket actual que forma el triángulo más grande
    double maxArea = -1;
    int maxAreaIndex = bucketStart;

    final pointA = data[a];

    for (int j = bucketStart; j < actualEnd; j++) {
      // Área del triángulo formado por pointA, data[j], y punto promedio
      final area = ((pointA.x - avgX) * (data[j].y - pointA.y) -
                   (pointA.x - data[j].x) * (avgY - pointA.y)).abs() * 0.5;

      if (area > maxArea) {
        maxArea = area;
        maxAreaIndex = j;
      }
    }

    sampled.add(data[maxAreaIndex]);
    a = maxAreaIndex;
  }

  // Siempre incluir el último punto
  sampled.add(data.last);

  return sampled;
}

/// Versión simplificada que toma el punto con mayor delta en cada bucket.
/// Más rápida que LTTB pero menos precisa visualmente.
List<DataPoint> maxDeltaDownsample(List<DataPoint> data, int threshold) {
  if (data.length <= threshold || threshold < 2) {
    return List.from(data);
  }

  final sampled = <DataPoint>[];
  final bucketSize = data.length / threshold;

  for (int i = 0; i < threshold; i++) {
    final start = (i * bucketSize).floor();
    final end = math.min(((i + 1) * bucketSize).floor(), data.length);

    if (start >= end) continue;

    // Encontrar el punto con mayor delta absoluto en el bucket
    var maxDelta = 0.0;
    var maxDeltaPoint = data[start];

    for (int j = start; j < end; j++) {
      final delta = j > 0 ? (data[j].y - data[j - 1].y).abs() : 0.0;
      if (delta > maxDelta) {
        maxDelta = delta;
        maxDeltaPoint = data[j];
      }
    }

    sampled.add(maxDeltaPoint);
  }

  return sampled;
}

/// Constante para límite de puntos en gráficas Flutter.
/// 200 puntos es un buen balance entre detalle visual y rendimiento.
const int kMaxChartPoints = 200;
