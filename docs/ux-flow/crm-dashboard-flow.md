# CRM Dashboard y Shell — UX Flow

## Resumen del flujo

El módulo CRM constituye el shell principal de la aplicación tras el login. Todos los roles (`admin`, `operator`, `viewer`) convergen en `CrmHomePage`, que contiene un `Drawer` lateral (`CrmDrawer`) y un dashboard consolidado (`CrmDashboardContent`). El dashboard muestra KPIs de dispositivos, alertas recientes, predicciones ML y warnings unificados. La navegación desde el drawer permite acceder a Dispositivos (con diferente experiencia según rol), Configuraciones (solo admin), Inteligencia (ML), Cuenta y Cerrar sesión.

## Pantallas involucradas

- **`CrmHomePage`** (`features/crm/presentation/pages/crm_home_page.dart`): Shell con AppBar, drawer y contenido del dashboard.
- **`CrmDashboardContent`** (`features/crm/presentation/widgets/crm_dashboard_content.dart`): Contenido dinámico con secciones de dashboard, predicciones y ML warnings.
- **`CrmDrawer`** (`features/crm/presentation/widgets/crm_drawer.dart`): Menú lateral de navegación principal.
- **`CrmAccountPage`** (`features/crm/presentation/pages/crm_account_page.dart`): Perfil de usuario con datos de sesión.
- **`CrmDevicesPage`** (`features/crm/presentation/pages/crm_devices_page.dart`): Lista paginada/buscable de dispositivos (para operator/viewer).
- **`CrmDeviceDetailsPage`** (`features/crm/presentation/pages/crm_device_details_page.dart`): Perfil completo de un dispositivo con sensores y métricas.
- **`CrmDeviceHistoryPage`** (`features/crm/presentation/pages/crm_device_history_page.dart`): Histórico de lecturas y métricas de un dispositivo.
- **`CrmDeviceAlertsPage`** (`features/crm/presentation/pages/crm_device_alerts_page.dart`): Alertas históricas de un dispositivo.
- **`CrmDeviceTypePage`** (`features/crm/presentation/pages/crm_device_type_page.dart`): Lista de dispositivos filtrada por tipo (eléctrico, frigorífico, ambiental).

## Flujo detallado

### CrmHomePage

#### Entrada
- **Desde**: `AppBootstrapper` (sesión restaurada) o `LoginPage` (login exitoso).
- **Parámetros**: `UserRole role`.
- **Autenticación**: Requiere sesión activa (token global en `ApiClient.authToken`).

#### Acciones y cadena de llamadas
1. **Render inicial diferido**
   - `initState()` programa un delay de 500ms vía `SchedulerBinding.instance.addPostFrameCallback` antes de marcar `_uiReady = true`.
   - Esto retrasa la construcción de `CrmDashboardContent` para evitar freeze en el primer frame.

2. **Refresh manual desde AppBar**
   - `IconButton` de refresh llama a `_dashboardKey.currentState?.refreshAll()` (línea 42 de `crm_home_page.dart`).

#### Estados visuales
- **Empty / Loading**: Hasta 500ms puede mostrar scaffold vacío mientras `_uiReady == false`.
- **Con datos**: `CrmDashboardContent` renderiza secciones.

#### Salida / Navegación
- Drawer lateral para navegar a otras pantallas.

### CrmDashboardContent

#### Entrada
- Es hijo de `CrmHomePage` (línea 59+ del build).

#### Acciones y cadena de llamadas
1. **Carga diferida de secciones**
   - `initState()` (línea 70-112):
     - Frame callback → delay 100ms `_initialRenderComplete = true`.
     - Delay 1200ms → `_refreshDashboard()` (carga `/crm/dashboard`).
     - Delay 3000ms → `_refreshMlSections()` (predicciones + ML warnings).
     - Delay 5000ms → `_startPolling()` (Timer periódico).

2. **Cadena de datos del dashboard**
   - `_refreshDashboard()` → `CrmRepository.fetchDashboard()` → `ApiClient.getJson('/crm/dashboard')`.
   - `_refreshMlSections()` → `MonitoringRepository.fetchPredictions()` + `AlertsRepository.fetchImportantAlerts()`.

3. **Polling**
   - Timer periódico refresca dashboard y secciones ML cada 30 segundos.

#### Endpoints involucrados

| Endpoint | Método | Momento | Datos enviados | Respuesta |
|----------|--------|---------|----------------|-----------|
| `/crm/dashboard` | GET | 1200ms después del primer frame | Query params opcionales (`from`, `to`, `alertsLimit`, etc.) | `CrmDashboardResponse` |
| `/monitoring/predictions` | GET | 3000ms después del primer frame | — | `List<PredictionViewModel>` |
| `/monitoring/ml-events/active` | GET | En `_refreshMlSections` | `limit=50` | ML events para alertas unificadas |
| `/monitoring/alerts/active` | GET | En `_refreshMlSections` | — | Alertas activas de umbral |

#### Estados visuales
- **Skeleton**: Mientras `_initialRenderComplete == false` o snapshots tienen `loading: true`.
- **Secciones reactivas**: Cada sección (dashboard, predicciones, warnings) usa `ValueNotifier<SectionSnapshot<T>>` para actualizar sin rebuild completo.
- **Error**: Si un snapshot falla, se muestra texto de error dentro de la sección afectada, no en toda la pantalla.

#### Salida / Navegación
- Navegación interna a detalle de alertas/dispositivos al tocar cards.

### CrmDrawer

#### Entrada
- Abierto desde `CrmHomePage` vía `Drawer`.

#### Acciones y cadena de llamadas
- Cada ítem del drawer usa `Navigator.pop(context)` para cerrar el drawer y luego `Navigator.of(context).push(MaterialPageRoute(...))`.
- **Dispositivos (admin)**: `DevicesHubPage(role)`.
- **Dispositivos (operator/viewer)**: `CrmDevicesPage(role)`.
- **Configuraciones (admin)**: `AdminPanelPage(currentRole: role)`.
- **Inteligencia**: `IntelligencePredictionsPage`, `IntelligenceHealthPage`, `IntelligenceDecisionsPage`.
- **Mi cuenta**: `CrmAccountPage(role)`.
- **Cerrar sesión**: Limpia token, storage, y hace `pushAndRemoveUntil` a `LoginPage`.

### CrmDevicesPage

#### Entrada
- Desde `CrmDrawer` para operator/viewer; o desde navegación interna.
- **Parámetros**: `UserRole role`.

#### Acciones y cadena de llamadas
1. **Carga inicial**
   - `initState()` → `_reload()` → `CrmRepository.listDevices(page:1, pageSize:100)` → `ApiClient.getJson('/crm/devices')`.
2. **Búsqueda**
   - `_searchController` con `_searchMode`. Al submit o cerrar búsqueda se llama `_reload()` con parámetro `q`.
3. **Agregar dispositivo (admin)**
   - `showAddDeviceDialog(...)` [PENDIENTE DE VERIFICAR] (referenciado pero no detallado en este scope).
4. **Refrescar**
   - IconButton refresh → `_reload()`.

#### Endpoints involucrados
- GET `/crm/devices?q=&page=&pageSize=`

#### Estados visuales
- **Loading**: `CircularProgressIndicator` mientras `FutureBuilder` espera.
- **Empty**: Texto "No hay dispositivos."
- **Error**: `Text('Error: ${snapshot.error}')`.

#### Salida / Navegación
- Tap en tile → `CrmDeviceDetailsPage(role, deviceId)`.

### CrmDeviceDetailsPage

#### Entrada
- Desde `CrmDevicesPage` o `CrmDeviceTypePage`.
- **Parámetros**: `role`, `deviceId`, `deviceNameHint`.

#### Acciones y cadena de llamadas
1. **Carga**
   - `initState()` → `_repo.getDeviceProfileFull(deviceId: widget.deviceId)` → GET `/crm/devices/{id}/profile-full`.
2. **Refresh**
   - IconButton refresh o pull-to-refresh (`RefreshIndicator`) → recarga el mismo future.

#### Endpoints involucrados
- GET `/crm/devices/{deviceId}/profile-full?maxPoints=400&maxSensors=6&alertsLimit=50`

#### Estados visuales
- **Loading**: `CircularProgressIndicator` centrado.
- **Error**: Texto centrado con error.
- **Con datos**: `DeviceDetailContent` con gráficas y métricas.

#### Salida / Navegación
- Puede navegar a histórico o alertas del dispositivo desde sub-widgets (no detallado en la page directamente; el contenido es `DeviceDetailContent`).

### CrmDeviceHistoryPage

#### Entrada
- Desde detalle de dispositivo.
- **Parámetros**: `role`, `deviceId`, `deviceNameHint`.

#### Acciones
- Carga `profile-full` con `maxSensors=20`, `maxPoints=600`, `alertsLimit=200`.
- Muestra gráficas y lecturas históricas.

#### Endpoints
- GET `/crm/devices/{deviceId}/profile-full?maxSensors=20&maxPoints=600&alertsLimit=200`

### CrmDeviceAlertsPage

#### Entrada
- Desde detalle de dispositivo.
- **Parámetros**: `role`, `deviceId`, `deviceNameHint`.

#### Acciones
- Carga alertas filtradas por `deviceId`, `pageSize=200`.
- Orden implícito por severidad y fecha.

#### Endpoints
- GET `/crm/alerts?deviceId={id}&pageSize=200`

### CrmDeviceTypePage

#### Entrada
- Desde navegación contextual o drawer indirecto.
- **Parámetros**: `role`, `deviceType`.

#### Acciones
- Filtra dispositivos por `type` y permite búsqueda dentro del tipo.
- Muestra chips de resumen (total, online, offline).

#### Endpoints
- GET `/crm/devices?type={deviceType}&page=1&pageSize=200`

### CrmAccountPage

#### Entrada
- Desde `CrmDrawer` → "Mi cuenta".
- **Parámetros**: `UserRole role`.

#### Acciones y cadena de llamadas
1. **Bootstrap de perfil**
   - Si `CurrentUser.value` es null (sesión restaurada sin pasar por login), llama `ApiClient.getJson('/auth/me')` para obtener datos del usuario.
2. **Refresh**
   - `RefreshIndicator` limpia `CurrentUser` y vuelve a llamar `_bootstrap()`.

#### Endpoints involucrados
- GET `/auth/me`

#### Estados visuales
- **Loading**: `CircularProgressIndicator` si `_loading == true`.
- **Error**: Texto con `_error`.
- **Con datos**: `AccountHeader` + `ProfileCard` con username, email, rol.

## Mapa de endpoints del módulo

| Endpoint | Método | Pantalla(s) que lo usan | Momento exacto del llamado | Dato crítico que retorna | Por qué se muestra en ese punto |
|----------|--------|------------------------|---------------------------|--------------------------|--------------------------------|
| `/crm/dashboard` | GET | `CrmDashboardContent` | 1200ms post-init | KPIs, alertas recientes, top devices | Resumen operativo del usuario |
| `/monitoring/predictions` | GET | `CrmDashboardContent` | 3000ms post-init | Lista de predicciones ML | Panel de predicciones del dashboard |
| `/monitoring/ml-events/active` | GET | `CrmDashboardContent`, `AlertsHubPage` | En carga ML / al abrir alertas | Eventos ML activos | Alertas unificadas con severidad |
| `/monitoring/alerts/active` | GET | `CrmDashboardContent`, `AlertsHubPage` | En carga ML / al abrir alertas | Alertas de umbral activas | Combinación con ML para alertas |
| `/crm/devices` | GET | `CrmDevicesPage`, `CrmDeviceTypePage` | `initState` y búsqueda/refresh | Lista paginada de dispositivos | Gestión y exploración de dispositivos |
| `/crm/devices/{id}/profile-full` | GET | `CrmDeviceDetailsPage`, `CrmDeviceHistoryPage` | `initState` y refresh | Perfil completo con sensores, lecturas, alertas | Detalle operativo del dispositivo |
| `/crm/alerts` | GET | `CrmDeviceAlertsPage` | `initState` | Alertas históricas filtradas | Histórico de alertas del dispositivo |
| `/auth/me` | GET | `CrmAccountPage` | `initState` si falta `CurrentUser` | Datos del usuario logueado | Mostrar perfil de cuenta |

## Diagnóstico UX

- 🔴 **Crítico**: `CrmDashboardContent` retrasa la carga de datos 1.2-5 segundos deliberadamente. Mejora percepción de velocidad pero ralentiza información crítica. Ideal sería mostrar skeleton inmediato y cargar en paralelo.
- 🟡 **Mejora**: `CrmDrawer` siempre muestra "Dashboard" como seleccionado (`isSelected: true`) aunque el usuario esté en otra pantalla; falta indicador de ruta activa.
- 🟡 **Mejora**: `CrmDevicesPage` no tiene paginación real en UI; carga `pageSize: 100` y scroll infinito no está implementado.
- 🟢 **Optimización**: El polling de dashboard cada 30 segundos consume batería; podría pausarse cuando la app está en background (no se observa `WidgetsBindingObserver` para lifecycle).
- 🟢 **Optimización**: `CrmDeviceDetailsPage` y `CrmDeviceHistoryPage` hacen la misma llamada a `profile-full` con diferentes parámetros; existe oportunidad de caché compartida.
