/// Re-exporta todos los modelos de salud ML por compatibilidad.
///
/// Este archivo mantiene compatibilidad con código existente que importa
/// desde health_models.dart. Los modelos ahora están organizados en archivos más pequeños.
library;

// Salud general
export 'ml_health_models.dart';

// Métricas de diagnóstico
export 'ml_diagnostic_metrics.dart';

// Actividad y anomalías
export 'ml_activity_models.dart';

// Patrones
export 'ml_pattern_models.dart';

// Micro-deltas y datos ignorados
export 'ml_microdelta_models.dart';

// View model de diagnóstico
export 'ml_diagnostic_viewmodel.dart';
