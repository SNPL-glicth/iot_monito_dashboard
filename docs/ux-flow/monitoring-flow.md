# Monitoreo y Telemetría de Sensores — UX Flow

## Resumen del flujo

El módulo de Monitoreo cubre la visualización de datos en tiempo real, lecturas históricas, diagnóstico crudo de sensores y el dashboard legacy administrativo. Es el módulo con mayor densidad de endpoints y complejidad de estados visuales. Usa una combinación de `Cubit` (`DashboardCubit`) para el dashboard heredado y `StatefulWidget` + `FutureBuilder` para las páginas de lecturas. El repositorio `MonitoringRepository` es un singleton que delega operaciones a sub-repositorios especializados.

## Pantallas involucradas

- **`DashboardPage`** (`features/monitoring/presentation/pages/dashboard_page.dart`): Dashboard legacy admin con lista de dispositivos y últimas lecturas.
- **`SensorReadingsPage`** (`features/monitoring/presentation/pages/sensor_readings_page.dart`): Lista histórica de lecturas de un sensor con filtrado por rango.
- **`SensorWeekReadingsPage`** (`features/monitoring/presentation/pages/sensor_week_readings_page.dart`): Lecturas agrupadas por día de la semana actual.
- **`SensorMonthPickerPage`** (`features/monitoring/presentation/pages/sensor_month_picker_page.dart`): Selector de mes para filtrar lecturas.
- **`SensorRawDiagnosisPage`** (`features/monitoring/presentation/pages/sensor_raw_diagnosis_page.dart`): Diagnóstico con lecturas crudas sin agregación, con gráfica y polling.
- **`RawSensorReadingsPage`** (`features/devices/presentation/widgets/raw_readings/raw_sensor_readings_page.dart`): Página de selección de sensor para lecturas crudas.

## Flujo detallado

### DashboardPage

#### Entrada
- Desde navegación legacy o deep links. **Nota**: está restringido a `UserRole.admin`; otros roles ven pantalla de "Acceso restringido".
- **Parámetros**: `UserRole role`.

#### Acciones y cadena de llamadas
1. **Carga de secciones**
   - `initState()` → `_refreshDevicesSection()`.
   - Cadena: `_repository.fetchDevicesWithSensors()` + `_repository.fetchLatestSensorReadings()` + `_repository.fetchSensorStatusBatch(sensorIds)`.
2. **Polling**
   - `_startPolling()` → Timer cada 10 segundos → `_refreshDevicesSection()`.
3. **Notificaciones (campana)**
   - `DashboardNotificationButton` muestra notificaciones del backend.
   - `_notificationsRepository.markAsRead(ids)` al tocar la campana.
4. **Logout forzado (no-admin)**
   - Si `widget.role != UserRole.admin`, muestra botón de logout que limpia sesión y hace `pushAndRemoveUntil` a `LoginPage`.

#### Endpoints involucrados
- GET `/monitoring/devices`
- GET `/monitoring/readings/latest`
- GET `/sensors/status/batch?ids=`
- POST `/notifications/mark-read`

#### Estados visuales
- **Loading**: `CircularProgressIndicator` mientras `_devicesSection` tiene `loading: true` y `data == null`.
- **Error**: Texto `Error: ${snapshot.error}` dentro de cada `ValueListenableBuilder`.
- **Empty**: Texto "No hay dispositivos registrados."
- **Con datos**: `DashboardDevicesSection` + `DashboardReadingsSection`.

#### Salida / Navegación
- Tap en sensor → `Navigator.pushNamed('/sensor/$sensorId')`.

### SensorReadingsPage

#### Entrada
- Desde `SensorDetailPage` o navegación directa.
- **Parámetros**: `role`, `sensorId`, `sensorNameHint`, `unitHint`, `limit`, `filterLabel`, `filterRange`.

#### Acciones y cadena de llamadas
1. **Carga**
   - `build()` crea future: `repo.fetchSensorReadings(sensorId, limit: limit, from: range.start, to: range.end)` → GET `/monitoring/sensors/{id}/readings?limit=&date_from=&date_to=`.
2. **Filtrado backend**
   - El backend filtra por rango de fecha; el cliente recibe solo lecturas dentro del periodo.

#### Endpoints
- GET `/monitoring/sensors/{sensorId}/readings?limit={limit}`

#### Estados visuales
- **Loading**: `CircularProgressIndicator`.
- **Error**: Texto centrado con estilo `DashboardTextStyles.error`.
- **Empty**: "No hay lecturas registradas."
- **Con datos**: `ListView.builder` de `Card` + `ListTile` con valor y timestamp formateado a Bogotá.

### SensorWeekReadingsPage

#### Entrada
- Desde detalle de sensor.
- **Parámetros**: `role`, `sensorId`, `sensorNameHint`, `unitHint`, `limit`.

#### Acciones y cadena de llamadas
1. **Carga**
   - `_load(repo)` → `NetworkClock.nowBogota()` → calcula lunes..domingo → `repo.fetchSensorReadings(sensorId, limit: 5000, from: monday, to: sunday)`.
   - El backend filtra por rango de semana; el cliente agrupa por día y ordena descendente por hora.
   - Filtra solo lecturas de tarde (12:00-22:59) y máximo 10 por día (`pickDayReadings`).
2. **Cache**
   - `MonitoringReadingsOps` mantiene cache en memoria por `(sensorId, from, to)` para evitar llamadas redundantes en la misma sesión.

#### Estados visuales
- **Loading**: `WeekReadingsSkeleton` (placeholder de header + 7 cards con shimmer).
- **Error**: Texto centrado con `DashboardTextStyles.error`.
- **Empty**: "No hay datos."
- **Con datos**: Lista de 7 `WeekDayCard` (uno por día). Día actual expandido automáticamente con chip "HOY".

#### Endpoints
- GET `/monitoring/sensors/{sensorId}/readings?limit=5000&date_from=&date_to=`

### SensorMonthPickerPage

#### Entrada
- Desde detalle de sensor.

#### Acciones
- Selector visual de mes.
- Al seleccionar, navega a `SensorReadingsPage` con `filterRange` y `filterLabel`.

#### Salida / Navegación
- push a `SensorReadingsPage(filterRange: ..., filterLabel: ...)`.

### SensorRawDiagnosisPage

#### Entrada
- Desde detalle de sensor.
- **Parámetros**: `role`, `sensorId`, `sensorName`, `unit`.

#### Acciones y cadena de llamadas
1. **Carga inicial**
   - `initState()` → `_loadData()` → `MonitoringRepository.fetchRawSensorReadings(sensorId, limit: _limit)` → GET `/monitoring/sensors/{id}/raw-readings?limit=&since=`.
2. **Polling**
   - Timer cada 10 segundos → `_loadData(silent: true)` para actualizar sin loading spinner.
3. **Cambio de límite**
   - `_limit` ajustable; recarga datos.

#### Endpoints
- GET `/monitoring/sensors/{sensorId}/raw-readings?limit=&since=`

#### Estados visuales
- **Loading**: indicador si `_loading == true` y no hay datos previos.
- **Error**: `RawDiagnosisErrorWidget` muestra código HTTP (ej. HTTP 404), mensaje detallado del backend y botón "Reintentar".
- **Empty**: `RawDiagnosisEmptyState` con icono y mensaje "Sin lecturas".
- **Realtime**: `_lastFetchedAt` muestra timestamp de última actualización en `RawDiagnosisStatsHeader`.
- **Gráfica**: `RawSensorChart` con scroll horizontal creciente (dentro de `RawDiagnosisSuccessBody`).
- **Lista**: `RawReadingsList` con valores puros (dentro de `RawDiagnosisSuccessBody`).

#### Modularización
- `RawDiagnosisErrorWidget`: error con código HTTP y retry.
- `RawDiagnosisStatsHeader`: contador de lecturas + timestamp.
- `RawDiagnosisEmptyState`: estado vacío estilizado.
- `RawDiagnosisSuccessBody`: layout de gráfica + lista.

## Mapa de endpoints del módulo

| Endpoint | Método | Pantalla(s) que lo usan | Momento exacto del llamado | Dato crítico que retorna | Por qué se muestra en ese punto |
|----------|--------|------------------------|---------------------------|--------------------------|--------------------------------|
| `/monitoring/devices` | GET | `DashboardPage`, `DevicesCategoriesPage` | `initState` | Dispositivos + sensores | Listado principal |
| `/monitoring/readings/latest` | GET | `DashboardPage`, `DevicesCategoriesPage` | `initState` | Últimas lecturas por sensor | Tarjetas de estado |
| `/sensors/status/batch` | GET | `DashboardPage` | Tras obtener devices | Status consolidado por sensor | Indicadores de salud en batch |
| `/monitoring/sensors/{id}/readings` | GET | `SensorReadingsPage`, `SensorWeekReadingsPage` | `build` / `_load` | Lecturas históricas | Exploración de datos |
| `/monitoring/sensors/{id}/raw-readings` | GET | `SensorRawDiagnosisPage` | `initState` + polling 10s | Lecturas crudas sin procesar | Diagnóstico técnico |
| `/monitoring/sensors/{id}/aggregated` | GET | `SensorDetailPage` | Carga inicial | Lecturas agregadas por bucket | Gráficas de tendencia |
| `/monitoring/sensors/{id}/historical-readings` | GET | [PENDIENTE] | Búsqueda por rango | Lecturas filtradas por fecha | Análisis temporal |
| `/monitoring/sensors/{id}/threshold-profile` | GET | `SensorThresholdsPage` | `initState` | Perfil de alertas | Configuración de umbrales |
| `/monitoring/alerts/active` | GET | `DashboardPage` (vía AlertsRepository) | `initState` / polling | Alertas activas | Indicadores de riesgo |
| `/monitoring/predictions` | GET | `DashboardPage` (vía MonitoringRepository) | `initState` / polling | Predicciones ML | Panel de proyección |

## Diagnóstico UX

- 🔴 **Crítico**: `DashboardPage` es legacy y restringido a admin, pero sigue existiendo en el router. Los usuarios no-admin que lleguen aquí ven solo un botón de logout sin explicación de por qué fueron redirigidos.
- 🟡 **Mejora**: `SensorRawDiagnosisPage` hace polling cada 10 segundos sin considerar si la pantalla está visible o si el sensor está seleccionado; consume recursos innecesariamente.
- 🟡 **Mejora**: `SensorWeekReadingsPage` limita arbitrariamente a 10 lecturas de tarde por día; el usuario no sabe que se omiten datos de la mañana.
- 🟢 **Optimización**: `SensorReadingsPage` carga `limit` lecturas y filtra por rango en cliente; sería más eficiente enviar `from/to` al backend.
- 🟢 **Optimización**: `DashboardPage` usa `ValueNotifier` por sección (bueno), pero el polling de 10 segundos para dispositivos + notificaciones genera tráfico constante sin backoff exponencial ante errores.
