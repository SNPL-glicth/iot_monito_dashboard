# Alertas y Gestión de Incidentes — UX Flow

## Resumen del flujo

El módulo de Alertas unifica dos fuentes de eventos: alertas de umbral tradicionales (exceso de temperatura, etc.) y eventos generados por Machine Learning (predicciones de anomalías). La pantalla principal `AlertsHubPage` muestra un historial prioritizado por severidad (crítico > warning > info). Desde aquí el usuario puede filtrar por sensor, navegar al detalle de una alerta (`AlertDetailPage`) y ver una gráfica "congelada" del momento exacto del incidente. Los roles admin y operator pueden acknowledge y resolver alertas; viewer solo puede consultar.

## Pantallas involucradas

- **`AlertsHubPage`** (`features/alerts/presentation/pages/alerts_hub_page.dart`): Centro de alertas con filtrado por sensor y lista priorizada.
- **`AlertDetailPage`** (`features/alerts/presentation/pages/alert_detail_page.dart`): Detalle de una alerta con snapshot inmutable, gráfica congelada y acciones (acknowledge / resolve).
- **`AlertFutureBuilder`** / widgets (`features/alerts/presentation/widgets/`): Componentes de lista, cards, y gráfica congelada (`frozen_alert_chart.dart`, etc.).

## Flujo detallado

### AlertsHubPage

#### Entrada
- Desde `CrmDrawer` → "Alertas" (para operator/viewer) o navegación contextual desde dashboard.
- Desde `ViewerDashboardPage` o `OperatorDashboardPage` drawers.
- **Parámetros**: `UserRole role`.

#### Acciones y cadena de llamadas
1. **Carga inicial**
   - `initState()` → `_loadAlerts(reset: true)`.
   - `_repo.listAlerts(sensorId: _selectedSensorId, page: 1, pageSize: 20)` → GET `/crm/alerts?sensorId=&page=1&pageSize=20`.
2. **Paginación (infinite scroll)**
   - `ScrollController` detecta cuando el usuario llega al 80% del scroll → `_loadMore()`.
   - Carga siguiente página (20 en 20) y acumula en `_items`.
   - Muestra `LinearProgressIndicator` al pie mientras carga más.
   - Texto "Sin más alertas" cuando `_items.length >= response.total`.
3. **Filtrado por sensor**
   - `_filterBySensor(sensorId, sensorName)` → reinicia lista y recarga página 1.
4. **Limpiar filtro**
   - `_clearFilter()` → reinicia lista y recarga.
5. **Tap en alerta**
   - Navega a `AlertDetailPage(alertId, sensorId, role)`.
   - Tras volver, `_refresh()` recarga desde página 1.

#### Endpoints involucrados
- GET `/crm/alerts?sensorId={id}&page={n}&pageSize=20`

#### Estados visuales
- **Loading**: `CircularProgressIndicator` en centro de pantalla durante carga inicial.
- **Loading más**: `LinearProgressIndicator` al pie de la lista durante `_loadMore`.
- **Empty**: Mensaje "No hay alertas registradas." (manejado en `AlertEmptyState`).
- **Con datos**: `AlertListView` con cards ordenados por severidad; footer dinámico según estado de paginación.
- **Filtro activo**: Chip/banner con nombre del sensor y botón "Limpiar".
- **Sin más**: Texto "Sin más alertas" al final de la lista cuando no hay más páginas.

#### Salida / Navegación
- push a `AlertDetailPage`.

### AlertDetailPage

#### Entrada
- Desde `AlertsHubPage` al tocar una alerta.
- **Parámetros**: `alertId`, `sensorId`, `role`.

#### Acciones y cadena de llamadas
1. **Carga de snapshot inmutable**
   - `CrmRepository.getAlertSnapshot(alertId)` → GET `/crm/alerts/{alertId}/snapshot`.
   - El snapshot contiene la serie temporal exacta al momento del trigger y los umbrales vigentes.
2. **Carga lazy de detalle de alerta**
   - `CrmRepository.getAlertById(alertId)` → intenta `GET /crm/alerts/{alertId}` (endpoint directo).
   - Si falla, fallback a `listAlerts(page: 1, pageSize: 20)` y busca el item en la primera página.
3. **Cache de alertas leídas**
   - `AlertDetailCache` mantiene en memoria alertas ya vistas por ID.
   - Al abrir un detalle ya visitado en la sesión, se evita la llamada al API.
4. **Acciones (admin/operator)**
   - **Acknowledge**: `CrmRepository.acknowledgeAlert(alertId)` → POST `/crm/alerts/{id}/ack`.
     - Optimistic update: el botón cambia a "ALERTA ATENDIDA" inmediatamente.
     - Si falla: revertir estado local y mostrar SnackBar de error.
   - **Resolve**: `CrmRepository.resolveAlert(alertId)` → POST `/crm/alerts/{id}/resolve`.
     - Mismo patrón de optimistic update + revert.
   - Botones desactivados mientras la acción está en vuelo (`acknowledging` / `resolving`).
5. **Navegación a sensor**
   - Desde el detalle se puede navegar al sensor asociado para ver contexto en tiempo real.

#### Endpoints involucrados
- GET `/crm/alerts/{alertId}/snapshot`
- GET `/crm/alerts` (implícito vía `getAlertById`)
- POST `/crm/alerts/{alertId}/ack`
- POST `/crm/alerts/{alertId}/resolve`

#### Estados visuales
- **Loading**: Skeleton o indicador mientras carga snapshot y detalle.
- **Snapshot**: Gráfica congelada (`FrozenAlertChart`) con líneas de umbral marcadas.
- **Acciones**: Botones de ack/resolve habilitados solo para admin/operator.
- **Error**: Mensaje si no se encuentra la alerta o falla el snapshot.

#### Salida / Navegación
- pop con resultado (puede devolver `true` para forzar refresh en `AlertsHubPage`).

## Mapa de endpoints del módulo

| Endpoint | Método | Pantalla(s) que lo usan | Momento exacto del llamado | Dato crítico que retorna | Por qué se muestra en ese punto |
|----------|--------|------------------------|---------------------------|--------------------------|--------------------------------|
| `/crm/alerts` | GET | `AlertsHubPage` | `initState` + refresh | Lista de alertas históricas paginadas | Centro de alertas del usuario |
| `/crm/alerts/{id}` | GET | `AlertDetailPage` (vía `getAlertById`) | `initState` | Alerta individual | Detalle sin descargar lista completa |
| `/crm/alerts/{id}/snapshot` | GET | `AlertDetailPage` | `initState` | Serie temporal congelada + umbrales | Contexto exacto del incidente |
| `/crm/alerts/{id}/ack` | POST | `AlertDetailPage` | Tap en "Atender" | Confirmación de ack | Transición de estado de alerta |
| `/crm/alerts/{id}/resolve` | POST | `AlertDetailPage` | Tap en "Resolver" | Confirmación de resolución | Cierre de incidente |
| `/monitoring/ml-events/active` | GET | `AlertsRepository` (vía AlertsHubPage/dashboard) | Carga de alertas unificadas | Eventos ML activos | Mezcla con alertas de umbral |
| `/monitoring/alerts/active` | GET | `AlertsRepository` (vía AlertsHubPage/dashboard) | Carga de alertas unificadas | Alertas de umbral activas | Panel de alertas importantes |

## Diagnóstico UX

- � **Resuelto**: `getAlertById` ahora intenta `GET /crm/alerts/{id}` directamente; fallback a primera página paginada (20 items). Ya no descarga 200 alertas.
- � **Resuelto**: `AlertsHubPage` tiene paginación 20 en 20 con infinite scroll y footer de estado.
- � **Resuelto**: Las acciones ack/resolve usan optimistic update con revert automático en error y SnackBar de feedback.
- 🟢 **Resuelto**: `AlertDetailCache` evita recargar alertas ya vistas en la sesión.
- 🟢 **Optimización**: El snapshot inmutable (`/snapshot`) es una excelente decisión arquitectónica para auditoría, pero podría precargarse al hacer hover/long-press en la lista para acelerar la apertura del detalle.
