/// Re-exporta todos los modelos de inteligencia por compatibilidad.
///
/// Este archivo mantiene compatibilidad con código existente que importa
/// desde intelligence_models.dart. Los modelos ahora están organizados por dominio.
library;

// Predicciones
export 'models/prediction/prediction_models.dart';

// Salud y diagnóstico ML
export 'models/health/health_models.dart';

// Decisiones del orquestador
export 'models/decision/decision_models.dart';
