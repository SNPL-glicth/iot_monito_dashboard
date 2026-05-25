# Centro de Inteligencia (ML) — UX Flow

## Resumen del flujo

El Centro de Inteligencia expone capacidades de Machine Learning al usuario final: predicciones de anomalías, estado de salud de los modelos, y decisiones recomendadas por el Decision Orchestrator. Las pantallas son principalmente de lectura, con la excepción de "Decisiones" donde el usuario puede cambiar el estado de una acción recomendada (ej. de `pending` a `accepted` o `dismissed`). Los datos provienen del backend NestJS y del servidor de telemetría (puerto 8099), ya que los cálculos ML se ejecutan fuera del backend principal para no saturarlo.

## Pantallas involucradas

- **`IntelligencePredictionsPage`** (`features/intelligence/presentation/pages/intelligence_predictions_page.dart`): Lista de predicciones ML resumidas.
- **`IntelligenceHealthPage`** (`features/intelligence/presentation/pages/intelligence_health_page.dart`): Estado de salud del modelo ML y métricas de calidad.
- **`IntelligenceDecisionsPage`** (`features/intelligence/presentation/pages/intelligence_decisions_page.dart`): Decisiones recomendadas por el orchestrator con acciones de usuario.

## Flujo detallado

### IntelligencePredictionsPage

#### Entrada
- Desde `CrmDrawer` → "Análisis ML".

#### Acciones y cadena de llamadas
1. **Carga**
   - `IntelligenceRepository.fetchLatestPredictions()` → GET `/intelligence/predictions?limit=50`.
   - Parsea a `List<PredictionSummaryViewModel>`.

#### Endpoints
- GET `/intelligence/predictions?limit=50`

#### Estados visuales
- **Loading**: `PredictionsSkeletonList` replica el layout de tarjetas (icono placeholder, barras de texto, chip, barra de progreso) para percepción de velocidad inmediata.
- **Empty**: Texto "Sin predicciones disponibles" o similar.
- **Con datos**: `PredictionCard` con título de predicción, sensor afectado, severidad, timestamp.

### IntelligenceHealthPage

#### Entrada
- Desde `CrmDrawer` → "Estado del modelo".

#### Acciones y cadena de llamadas
1. **Carga de salud ML (backend)**
   - `IntelligenceRepository.fetchMlHealth()` → GET `/monitoring/ml-health`.
2. **Carga de diagnóstico (telemetry)**
   - `IntelligenceRepository.fetchMlDiagnostic()` → GET `{telemetryUrl}/diagnostics/ml/model-status`.
3. **Insights del orchestrator (telemetry)**
   - `IntelligenceRepository.fetchOrchestratorInsights()` → GET `{telemetryUrl}/diagnostics/orchestrator/insights`.

#### Endpoints
- GET `/monitoring/ml-health`
- GET `/diagnostics/ml/model-status` (telemetry server)
- GET `/diagnostics/orchestrator/insights` (telemetry server)

#### Estados visuales
- **Loading**: `LoadingStateWidget` hasta que el endpoint responde.
- **Secciones**: Estado del modelo con semáforo visual (`HealthHeaderWidget`), métricas de error/calidad, actividad reciente.
- **Semáforo**: 3 luces (ACC, DRIFT, FRESH) con colores verde/amarillo/rojo según umbrales configurables en `MlHealthThresholds`.
- **Error del orchestrator**: `OrchestratorErrorWidget` muestra último ping conocido, timestamp del último dato válido y botón de reintentar. Si hay datos previos, se muestran con un banner de advertencia en lugar de bloquear toda la pantalla.

### IntelligenceDecisionsPage

#### Entrada
- Desde `CrmDrawer` → "Decisiones".

#### Acciones y cadena de llamadas
1. **Carga**
   - `IntelligenceRepository.fetchDecisions(status, severity, limit: 50)` → GET `/intelligence/decisions?limit=50&status=&severity=`.
2. **Cambio de estado de decisión**
   - Tap en acción (aceptar/descartar/etc.) → `IntelligenceRepository.updateDecisionStatus(decisionId, newStatus)` → PATCH `/intelligence/decisions/{id}/status`.
   - Recarga lista tras éxito.

#### Endpoints
- GET `/intelligence/decisions?limit=50`
- PATCH `/intelligence/decisions/{id}/status`

#### Estados visuales
- **Loading**: Indicador.
- **Con datos**: Lista de decisiones con título, contexto, severidad, fecha y botones de acción.
- **Empty**: "No hay decisiones pendientes."
- **Post-acción**: Feedback visual (snackbar o cambio de chip de estado).

## Mapa de endpoints del módulo

| Endpoint | Método | Pantalla(s) que lo usan | Momento exacto del llamado | Dato crítico que retorna | Por qué se muestra en ese punto |
|----------|--------|------------------------|---------------------------|--------------------------|--------------------------------|
| `/intelligence/predictions` | GET | `IntelligencePredictionsPage` | `initState` | Predicciones ML resumidas | Análisis de tendencias |
| `/monitoring/ml-health` | GET | `IntelligenceHealthPage` | `initState` | Estado general del sistema ML | Indicador de salud del modelo |
| `/diagnostics/ml/model-status` | GET | `IntelligenceHealthPage` | `initState` | Métricas técnicas del modelo | Diagnóstico detallado |
| `/diagnostics/orchestrator/insights` | GET | `IntelligenceHealthPage` | `initState` | Narrativa de análisis (ruido, spikes, señales débiles) | Contexto interpretativo para operadores |
| `/intelligence/decisions` | GET | `IntelligenceDecisionsPage` | `initState` | Decisiones recomendadas | Lista de acciones propuestas |
| `/intelligence/decisions/{id}/status` | PATCH | `IntelligenceDecisionsPage` | Tap en acción de cambio de estado | Decisión actualizada | Confirmar o descartar recomendación |

## Diagnóstico UX

- � **Resuelto**: `IntelligencePredictionsPage` usa `PredictionsSkeletonList` con placeholder de tarjetas en lugar de spinner genérico.
- 🟢 **Resuelto**: `HealthHeaderWidget` incluye semáforo visual (ACC/DRIFT/FRESH) con umbrales configurables en `MlHealthThresholds`.
- 🟢 **Resuelto**: `IntelligenceDecisionsPage` consume prefetch de decisiones iniciado desde `CrmDrawer` al tocar cualquier ítem de inteligencia.
- 🟢 **Resuelto**: `IntelligenceHealthPage` maneja errores del orchestrator con `OrchestratorErrorWidget` (retry + último ping + timestamp), mostrando datos previos si existen.
- 🟡 **Mejora**: No hay explicación en pantalla de qué significa cada métrica de salud ML (precision, recall, drift, etc.); usuarios no técnicos pueden no entender los valores.
- 🟢 **Optimización**: Las decisiones podrían agruparse por severidad con badges de conteo, en lugar de una lista plana, para que el operador priorice visualmente.
