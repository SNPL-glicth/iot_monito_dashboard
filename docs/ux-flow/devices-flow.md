# Dispositivos y Provisioning — UX Flow

## Resumen del flujo

El módulo de Dispositivos gestiona el ciclo de vida completo de los equipos IoT y sus sensores: creación lógica, definición de métricas, activación física (publish/reserve/confirm), exploración por categorías, visualización de detalle y mantenimiento (limpieza de lecturas). Los administradores tienen acceso total; operadores y viewers tienen acceso limitado según scoping del backend. El flujo de provisioning de sensores usa un wizard de pasos con QR para activación física.

## Pantallas involucradas

- **`DevicesHubPage`** (`features/devices/presentation/pages/devices_hub_page.dart`): Centro de acceso a categorías, comandos remotos y limpieza de lecturas.
- **`DevicesCategoriesPage`** (`features/devices/presentation/pages/devices_categories_page.dart`): Lista de dispositivos agrupados con sensores y últimas lecturas.
- **`DevicesListPage`** (`features/devices/presentation/pages/devices_list_page.dart`): Lista filtrada/plana de dispositivos.
- **`DevicesByCategoryPage`** (`features/devices/presentation/pages/devices_by_category_page.dart`): Dispositivos filtrados por categoría/tipo.
- **`DeviceDetailPage`** (`features/devices/presentation/pages/device_detail_page.dart`): Detalle de un dispositivo con lista de sensores.
- **`SensorDetailPage`** / **`SensorDetailsRoutePage`** (`features/devices/presentation/pages/sensor_detail_page.dart` / `sensor_details_route_page.dart`): Detalle de un sensor con lecturas, umbrales y gráficas.
- **`AddDeviceScreen`** (`features/devices/presentation/pages/add_device_screen.dart`): Wizard para crear dispositivo y definir/activar sensores.
- **`DevicesCleanReadingsPage`** (`features/devices/presentation/pages/devices_clean_readings_page.dart`): Herramienta de mantenimiento para eliminar lecturas crudas (admin only).
- **`SensorThresholdsPage`** (`features/devices/presentation/pages/sensor_thresholds_page.dart`): Configuración de umbrales de alerta para un sensor.

## Flujo detallado

### DevicesHubPage

#### Entrada
- Desde `CrmDrawer` (admin) o navegación contextual.
- **Parámetros**: `UserRole role`.

#### Acciones y cadena de llamadas
1. **Tap en "Dispositivos y sensores"**
   - `_openCategories(context)` → push `DevicesCategoriesPage(role)`.
2. **Tap en "Comandos remotos"**
   - `_comingSoon()` → AlertDialog genérico.
3. **Tap en "Limpiar lecturas" (admin)**
   - push `DevicesCleanReadingsPage()`.

#### Estados visuales
- Cards con iconos grandes y subtítulos descriptivos.
- Badge "Pronto" en comandos remotos (`isComingSoon`).

#### Salida / Navegación
- push a `DevicesCategoriesPage` o `DevicesCleanReadingsPage`.

### DevicesCategoriesPage

#### Entrada
- Desde `DevicesHubPage`.
- **Parámetros**: `UserRole role`.

#### Acciones y cadena de llamadas
1. **Carga inicial**
   - `initState()` → `Future.wait([_repo.fetchDevicesWithSensors(), _repo.fetchLatestSensorReadings()])`.
   - `fetchDevicesWithSensors()` → GET `/monitoring/devices`.
   - `fetchLatestSensorReadings()` → GET `/monitoring/readings/latest`.
2. **Tap en tarjeta de dispositivo**
   - push `DeviceDetailPage(role, deviceId, deviceName)`.
3. **Agregar dispositivo (admin)**
   - `IconButton` → `Navigator.pushNamed('/devices/create')`.

#### Estados visuales
- **Loading**: `CircularProgressIndicator`.
- **Empty**: Icono + texto "No hay dispositivos registrados".
- **Con datos**: Header gradiente + lista de tarjetas con status online/offline, conteo de sensores, última lectura.

#### Endpoints involucrados
- GET `/monitoring/devices`
- GET `/monitoring/readings/latest`

### DeviceDetailPage

#### Entrada
- Desde `DevicesCategoriesPage`, `DevicesByCategoryPage`, o rutas dinámicas (`/device/{id}`).
- **Parámetros**: `role`, `deviceId`, `deviceName`.

#### Acciones y cadena de llamadas
1. **Carga**
   - `initState()` → carga datos del dispositivo y sensores.
   - [PENDIENTE DE VERIFICAR] repositorio exacto usado en esta page; posiblemente `MonitoringRepository` o `ProvisioningRepository`.
2. **Tap en sensor**
   - Navega a `SensorDetailsRoutePage` o `SensorDetailPage`.

#### Estados visuales
- Loading, error, lista de sensores con tiles.

### SensorDetailPage / SensorDetailsRoutePage

#### Entrada
- Desde `DeviceDetailPage` o ruta dinámica `/sensor/{id}`.
- **Parámetros**: `args: SensorDetailsArgs(sensorId)` o `role + sensorId`.

#### Acciones y cadena de llamadas
1. **Carga**
   - `SensorDetailViewModel.loadInitial()` → `TelemetryRepository.fetchRealtimeData(sensorId)` + `TelemetryRepository.fetchSensorDashboard(sensorId, range: '6h')`.
   - Endpoints: GET `/monitoring/sensors/{id}/readings`, GET `/monitoring/sensors/{id}/aggregated` (o similar en telemetry).
2. **Polling**
   - Timer periódico recarga datos en tiempo real.
3. **Cambio de rango temporal**
   - Selección de rango (1h, 6h, 24h, 7d) recarga `fetchSensorDashboard`.

#### Estados visuales
- **Loading inicial**: indicador hasta que `loadInitial()` completa.
- **Realtime**: datos actualizados cada X segundos.
- **Error**: mensaje si falla la carga.

#### Salida / Navegación
- push a `SensorReadingsPage`, `SensorRawDiagnosisPage`, `SensorThresholdsPage`, `SensorWeekReadingsPage`, `SensorMonthPickerPage` desde botones/contexto.

### AddDeviceScreen

#### Entrada
- Desde `DevicesCategoriesPage` (admin) o ruta `/devices/create`.

#### Acciones y cadena de llamadas
1. **Paso 1: Crear dispositivo**
   - Formulario de nombre/modelo → `ProvisioningRepository.createDevice(name, model)` → POST `/devices/create`.
   - Retorna `deviceUuid`.
2. **Paso 2: Definir sensor**
   - Selección de tipo, unidad, umbrales (warningMin/Max, alertMin/Max).
   - `ProvisioningRepository.defineSensor(deviceUuid, ...)` → POST `/devices/{uuid}/sensors/define`.
   - Retorna `sensorUuid`.
3. **Paso 3: Activación**
   - Opciones:
     a) **Con QR**: `publishSensor` → `reserveSensor` → escaneo de QR → `confirmSensor`.
     b) **Sin QR / flujo admin**: `SensorActivationService.activateSensorWithCode(sensorUuid)` que encadena publish → reserve → confirm.
   - Endpoints: POST `/devices/sensors/{uuid}/publish`, POST `/devices/sensors/{uuid}/reserve`, POST `/devices/sensors/confirm`.
   - Al confirmar retorna `apiKey` (solo se muestra una vez).

#### Endpoints involucrados
- POST `/devices/create`
- POST `/devices/{uuid}/prepare-activation` (legacy)
- POST `/devices/{uuid}/sensors/define`
- POST `/devices/sensors/{uuid}/publish`
- GET `/devices/sensors/claimable`
- POST `/devices/sensors/{uuid}/reserve`
- POST `/devices/sensors/confirm`
- POST `/devices/{uuid}/sensors` (legacy add sensor)

#### Estados visuales
- **Step indicator**: Indica paso actual (0: crear, 1: definir, 2: activar, 3: éxito).
- **Loading**: `_isLoading` bloquea controles y muestra indicador.
- **Error**: `_error` se muestra como SnackBar o texto rojo.
- **Éxito**: Vista `DeviceSuccessView` con API Key resaltada y botón para copiar.

#### Salida / Navegación
- Tras éxito, generalmente pop o navegación a `DevicesCategoriesPage`.

### DevicesCleanReadingsPage

#### Entrada
- Desde `DevicesHubPage` (admin only).

#### Acciones y cadena de llamadas
1. **Eliminar todas las lecturas**
   - Botón → `ApiClient.delete('/monitoring/dev-tools/sensor-readings/all')`.
2. **Eliminar por sensor**
   - Input de `sensorId` → `ApiClient.delete('/monitoring/dev-tools/sensor-readings/sensor/{sensorId}')`.

#### Endpoints
- DELETE `/monitoring/dev-tools/sensor-readings/all`
- DELETE `/monitoring/dev-tools/sensor-readings/sensor/{sensorId}`

#### Estados visuales
- Confirmación visual con texto de éxito (`_message`) tras operación.
- Sin confirmación modal previa (acción destructiva directa).

### SensorThresholdsPage

#### Entrada
- Desde `SensorDetailPage` o navegación directa.
- **Parámetros**: `role`, `sensorId`.

#### Acciones y cadena de llamadas
1. **Carga de perfil**
   - `MonitoringRepository.fetchSensorThresholdProfile(sensorId)` → GET `/monitoring/sensors/{id}/threshold-profile`.
2. **Carga de umbrales**
   - `MonitoringRepository.fetchSensorThresholds(sensorId)` → GET `/monitoring/sensors/{id}/thresholds`.
3. **Crear umbral**
   - POST `/monitoring/sensors/{id}/thresholds`.
4. **Editar umbral**
   - PATCH `/monitoring/thresholds/{id}`.
5. **Desactivar umbral**
   - DELETE `/monitoring/thresholds/{id}?reason=`.
6. **Ver historial**
   - GET `/monitoring/thresholds/{id}/history`.

## Mapa de endpoints del módulo

| Endpoint | Método | Pantalla(s) que lo usan | Momento exacto del llamado | Dato crítico que retorna | Por qué se muestra en ese punto |
|----------|--------|------------------------|---------------------------|--------------------------|--------------------------------|
| `/monitoring/devices` | GET | `DevicesCategoriesPage` | `initState` | Lista de dispositivos con sensores | Exploración de dispositivos |
| `/monitoring/readings/latest` | GET | `DevicesCategoriesPage` | `initState` | Últimas lecturas por sensor | Mostrar valor/timestamp reciente en tarjeta |
| `/devices/create` | POST | `AddDeviceScreen` | Paso 1 del wizard | `deviceUuid` | Identificar dispositivo nuevo |
| `/devices/{uuid}/sensors/define` | POST | `AddDeviceScreen` | Paso 2 del wizard | `sensorUuid` | Configurar métricas del sensor |
| `/devices/sensors/{uuid}/publish` | POST | `AddDeviceScreen` | Paso 3 (admin) | Estado publicado | Hacer sensor claimable |
| `/devices/sensors/{uuid}/reserve` | POST | `AddDeviceScreen` | Paso 3 (admin) | `claimToken` | Reservar para instalador |
| `/devices/sensors/confirm` | POST | `AddDeviceScreen` | Tras escanear QR o flujo admin | `apiKey` | Activar sensor físicamente |
| `/devices/sensors/claimable` | GET | [PENDIENTE] | — | Lista de sensores pendientes | Instalador selecciona sensor |
| `/monitoring/sensors/{id}/threshold-profile` | GET | `SensorThresholdsPage` | `initState` | Perfil de umbrales | Configuración de alertas |
| `/monitoring/sensors/{id}/thresholds` | GET/POST | `SensorThresholdsPage` | Carga y creación | Umbrales del sensor | CRUD de umbrales |
| `/monitoring/thresholds/{id}` | PATCH/DELETE | `SensorThresholdsPage` | Editar/desactivar | Umbral actualizado | Mantenimiento de reglas |
| `/monitoring/thresholds/{id}/history` | GET | `SensorThresholdsPage` | Ver historial | Cambios en umbrales | Auditoría de configuración |
| `/monitoring/dev-tools/sensor-readings/all` | DELETE | `DevicesCleanReadingsPage` | Tap en botón destruir todo | Confirmación de eliminación | Mantenimiento de datos |
| `/monitoring/dev-tools/sensor-readings/sensor/{id}` | DELETE | `DevicesCleanReadingsPage` | Tap en botón por sensor | Confirmación de eliminación | Limpieza selectiva |

## Diagnóstico UX

- 🔴 **Crítico**: `DevicesCleanReadingsPage` no pide confirmación antes de ejecutar DELETE; el usuario puede destruir datos históricos sin advertencia clara.
- 🔴 **Crítico**: En `AddDeviceScreen`, si el flujo de activación falla en `reserve` o `confirm`, el sensor queda en estado intermedio (PENDING_CLAIM o PENDING_CONFIRMATION) sin opción visible de retry o rollback desde la UI.
- 🟡 **Mejora**: `DevicesCategoriesPage` carga dos futures en paralelo pero no tiene manejo de error granular; si uno falla, ambos se consideran erróneos.
- 🟡 **Mejora**: `SensorDetailPage` no muestra skeleton mientras carga; salta de vacío a datos completos.
- 🟢 **Optimización**: El wizard de `AddDeviceScreen` usa un `PageView` o steps manuales [PENDIENTE DE VERIFICAR]; sería útil persistir progreso si el usuario sale accidentalmente.
