/// Re-exporta todos los modelos de decisiones por compatibilidad.
///
/// Este archivo mantiene compatibilidad con código existente que importa
/// desde decision_models.dart. Los modelos ahora están organizados en archivos más pequeños.
library;

// Acciones de decisión
export 'decision_action_models.dart';

// Análisis de cambios y spikes
export 'analysis_models.dart';

// Tareas y señales
export 'task_signal_models.dart';

// Modelos del orquestador
export 'orchestrator_models.dart';
