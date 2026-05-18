/// Configuración de tipos de sensor para escalado dinámico y visualización.
/// 
/// FIX CRÍTICO: Cada tipo de sensor tiene características diferentes:
/// - Rango esperado de valores
/// - Resolución válida (decimales significativos)
/// - Ruido permitido (variación normal)
/// - Padding visual para gráficas
library;

/// Configuración de un tipo de sensor.
class SensorTypeConfig {
  const SensorTypeConfig({
    required this.type,
    required this.displayName,
    required this.defaultUnit,
    required this.expectedMin,
    required this.expectedMax,
    required this.resolution,
    required this.noiseFloor,
    required this.chartPaddingPercent,
  });

  /// Tipo de sensor (lowercase)
  final String type;
  
  /// Nombre para mostrar
  final String displayName;
  
  /// Unidad por defecto
  final String defaultUnit;
  
  /// Valor mínimo esperado en condiciones normales
  final double expectedMin;
  
  /// Valor máximo esperado en condiciones normales
  final double expectedMax;
  
  /// Número de decimales significativos
  final int resolution;
  
  /// Variación normal (ruido) que no debe considerarse cambio real
  final double noiseFloor;
  
  /// Porcentaje de padding para gráficas (0.1 = 10%)
  final double chartPaddingPercent;
  
  /// Rango esperado
  double get expectedRange => expectedMax - expectedMin;
  
  /// Calcula el padding visual para una gráfica
  double calculateChartPadding(double dataMin, double dataMax) {
    final dataRange = dataMax - dataMin;
    if (dataRange < noiseFloor * 2) {
      // Si el rango de datos es muy pequeño, usar el rango esperado
      return expectedRange * chartPaddingPercent;
    }
    return dataRange * chartPaddingPercent;
  }
  
  /// Ajusta los límites de la gráfica para evitar el efecto "apachurrado"
  ({double min, double max}) adjustChartBounds(double dataMin, double dataMax) {
    final dataRange = dataMax - dataMin;
    
    // Si el rango es muy pequeño (datos casi constantes), expandir
    if (dataRange < noiseFloor * 5) {
      final center = (dataMin + dataMax) / 2;
      final minRange = expectedRange * 0.1; // Mínimo 10% del rango esperado
      return (
        min: center - minRange / 2,
        max: center + minRange / 2,
      );
    }
    
    // Aplicar padding normal
    final padding = dataRange * chartPaddingPercent;
    return (
      min: dataMin - padding,
      max: dataMax + padding,
    );
  }
  
  /// Formatea un valor según la resolución del sensor
  String formatValue(double value) {
    return value.toStringAsFixed(resolution);
  }
}

/// Configuraciones predefinidas por tipo de sensor.
class SensorTypeConfigs {
  SensorTypeConfigs._();
  
  static const temperature = SensorTypeConfig(
    type: 'temperature',
    displayName: 'Temperatura',
    defaultUnit: '°C',
    expectedMin: -20,
    expectedMax: 60,
    resolution: 1,
    noiseFloor: 0.5,
    chartPaddingPercent: 0.15,
  );
  
  static const humidity = SensorTypeConfig(
    type: 'humidity',
    displayName: 'Humedad',
    defaultUnit: '%',
    expectedMin: 0,
    expectedMax: 100,
    resolution: 0,
    noiseFloor: 2.0,
    chartPaddingPercent: 0.10,
  );
  
  static const pressure = SensorTypeConfig(
    type: 'pressure',
    displayName: 'Presión',
    defaultUnit: 'hPa',
    expectedMin: 900,
    expectedMax: 1100,
    resolution: 1,
    noiseFloor: 0.5,
    chartPaddingPercent: 0.05,
  );
  
  static const airQuality = SensorTypeConfig(
    type: 'air_quality',
    displayName: 'Calidad de Aire',
    defaultUnit: 'ppm',
    expectedMin: 0,
    expectedMax: 5000,
    resolution: 0,
    noiseFloor: 50.0,
    chartPaddingPercent: 0.15,
  );
  
  static const voltage = SensorTypeConfig(
    type: 'voltage',
    displayName: 'Voltaje',
    defaultUnit: 'V',
    expectedMin: 0,
    expectedMax: 250,
    resolution: 1,
    noiseFloor: 1.0,
    chartPaddingPercent: 0.10,
  );
  
  static const power = SensorTypeConfig(
    type: 'power',
    displayName: 'Potencia',
    defaultUnit: 'W',
    expectedMin: 0,
    expectedMax: 10000,
    resolution: 0,
    noiseFloor: 10.0,
    chartPaddingPercent: 0.15,
  );
  
  static const current = SensorTypeConfig(
    type: 'current',
    displayName: 'Corriente',
    defaultUnit: 'A',
    expectedMin: 0,
    expectedMax: 100,
    resolution: 2,
    noiseFloor: 0.1,
    chartPaddingPercent: 0.10,
  );
  
  static const ph = SensorTypeConfig(
    type: 'ph',
    displayName: 'pH',
    defaultUnit: '',
    expectedMin: 0,
    expectedMax: 14,
    resolution: 2,
    noiseFloor: 0.1,
    chartPaddingPercent: 0.10,
  );
  
  static const level = SensorTypeConfig(
    type: 'level',
    displayName: 'Nivel',
    defaultUnit: '%',
    expectedMin: 0,
    expectedMax: 100,
    resolution: 0,
    noiseFloor: 1.0,
    chartPaddingPercent: 0.10,
  );
  
  static const flow = SensorTypeConfig(
    type: 'flow',
    displayName: 'Flujo',
    defaultUnit: 'L/min',
    expectedMin: 0,
    expectedMax: 1000,
    resolution: 1,
    noiseFloor: 5.0,
    chartPaddingPercent: 0.15,
  );
  
  /// Configuración por defecto para tipos desconocidos
  static const defaultConfig = SensorTypeConfig(
    type: 'default',
    displayName: 'Sensor',
    defaultUnit: '',
    expectedMin: 0,
    expectedMax: 100,
    resolution: 2,
    noiseFloor: 0.1,
    chartPaddingPercent: 0.15,
  );
  
  /// Mapa de configuraciones por tipo
  static final Map<String, SensorTypeConfig> _configs = {
    'temperature': temperature,
    'humidity': humidity,
    'pressure': pressure,
    'air_quality': airQuality,
    'airquality': airQuality,
    'voltage': voltage,
    'power': power,
    'current': current,
    'ph': ph,
    'level': level,
    'flow': flow,
  };
  
  /// Obtiene la configuración para un tipo de sensor.
  /// Retorna defaultConfig si el tipo no está definido.
  static SensorTypeConfig getConfig(String? sensorType) {
    if (sensorType == null || sensorType.isEmpty) {
      return defaultConfig;
    }
    final normalized = sensorType.toLowerCase().trim().replaceAll(' ', '_');
    return _configs[normalized] ?? defaultConfig;
  }
  
  /// Verifica si un tipo de sensor está configurado
  static bool hasConfig(String sensorType) {
    final normalized = sensorType.toLowerCase().trim().replaceAll(' ', '_');
    return _configs.containsKey(normalized);
  }
}
