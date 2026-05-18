# Auditoria Frontend Flutter

**Fecha:** 2026-05-14
**Auditor:** Windsurf AI
**Alcance:** `lib/` completo (99 archivos .dart analizados)

## Resumen Ejecutivo

El proyecto presenta una deuda tecnica considerable concentrada principalmente en la capa de presentacion (widgets/pages). Se detectaron 47 archivos que superan las 180 lineas efectivas de codigo, con build() metodos que llegan a las 351 lineas. La arquitectura sigue un patron ad-hoc donde los widgets gestionan directamente repositorios, polling, cache y navegacion, mezclando logica de negocio con UI. No hay evidencia de uso de BLoC, Riverpod ni Provider como capa de estado intermedia. Existen riesgos de memory leaks por controllers/listeners sin dispose, uso de `!` forzado en decenas de lugares, y context usado de forma insegura tras await. La prioridad de refactor es alta: se recomienda extraer ViewModels e inyectar dependencias antes de escalar funcionalidad.

---

## 1. Archivos que superan 180 lineas

| Archivo | Lineas efectivas | build() mas largo | Propuesta de division |
|---|---|---|---|
| `lib/features/devices/presentation/pages/sensor_detail_page.dart` | 1733 | 162 | Extraer `_buildBody` -> `SensorDetailBody`, `_buildChart` -> `SensorChartPanel`, `_buildMetricsCard` -> `SensorMetricsCard`, `_buildThresholdSection` -> `ThresholdSectionWidget`. Crear `SensorDetailViewModel` para manejar polling y repos. |
| `lib/features/intelligence/presentation/pages/intelligence_health_page.dart` | 1308 | 108 | Extraer secciones de UI por pestana a `HealthTabWidget`, `PredictionsTabWidget`, `AnomaliesTabWidget`. Mover logica de fetch a `IntelligenceViewModel`. |
| `lib/features/devices/presentation/widgets/define_sensor_flow.dart` | 993 | 96 | Separar cada paso del wizard en widgets independientes: `SensorTypeStep`, `SensorConfigStep`, `SensorReviewStep`. Crear `DefineSensorFlowController`. |
| `lib/features/monitoring/data/models/monitoring_view_models.dart` | 975 | - | Es un archivo de modelos con ~975 LOC. Dividir por dominio: `sensor_view_models.dart`, `device_view_models.dart`, `dashboard_view_models.dart`, `reading_view_models.dart`. |
| `lib/features/intelligence/data/intelligence_models.dart` | 892 | - | Separar en `ml_prediction_models.dart`, `health_models.dart`, `decision_models.dart`. |
| `lib/features/crm/presentation/widgets/crm_dashboard_content.dart` | 870 | 95 | Extraer cards individuales: `KpiCard`, `DeviceStatusCard`, `AlertSummaryCard`, `RecentActivityList`. Crear `CrmDashboardViewModel`. |
| `lib/features/monitoring/presentation/pages/dashboard_page.dart` | 784 | 320 | El build() tiene 320 lineas. Extraer `DashboardHeader`, `DashboardGrid`, `SensorSummarySection`, `AlertTickerWidget`. Mover polling a `DashboardViewModel`. |
| `lib/features/devices/presentation/widgets/ml_enhanced_chart.dart` | 659 | 22 | Separar capas de overlay ML en `MlOverlayWidget`, `PredictionBandPainter`. Mover logica de fetch a ViewModel. |
| `lib/features/devices/presentation/pages/device_detail_page.dart` | 637 | 351 | Extraer `DeviceInfoCard`, `DeviceSensorsList`, `DeviceActionsBar`. Mover repos a `DeviceDetailViewModel`. |
| `lib/features/intelligence/presentation/pages/intelligence_decisions_page.dart` | 625 | 20 | Extraer `DecisionListWidget`, `DecisionFilterBar`. Mover carga a ViewModel. |
| `lib/features/devices/presentation/widgets/optimized_realtime_chart.dart` | 608 | 20 | Separar `RealtimeChartPainter`, `ChartLegendWidget`. |
| `lib/features/alerts/presentation/pages/alert_detail_page.dart` | 598 | 37 | Extraer `AlertTimelineWidget`, `AlertMetricsCard`, `AlertActionsBar`. Mover repos a `AlertDetailViewModel`. |
| `lib/features/devices/presentation/widgets/ml_model_state_widget.dart` | 575 | 30 (x5) | Es un widget con multiples build helpers. Extraer `ModelTrainingIndicator`, `ModelMetricsGrid`, `ModelDriftAlert`. |
| `lib/features/devices/presentation/widgets/raw_readings_chart.dart` | 569 | 68 | Extraer `RawChartPainter`, `ReadingTooltip`. |
| `lib/features/devices/presentation/widgets/candlestick_chart.dart` | 568 | 28 | Extraer `CandlestickPainter`, `VolumeBarPainter`. |
| `lib/features/crm/presentation/widgets/notification_bell_widget.dart` | 552 | 133 | Extraer `NotificationListView`, `NotificationBadge`. Mover `NotificationStateService` a Provider inyectado. |
| `lib/features/devices/presentation/pages/sensor_thresholds_page.dart` | 536 | 156 | Extraer `ThresholdFormWidget`, `ThresholdHistoryChart`. |
| `lib/features/alerts/presentation/widgets/frozen_alert_chart.dart` | 455 | 303 | El build() tiene 303 lineas. Extraer `FrozenChartArea`, `AlertAnnotationLayer`. |
| `lib/features/alerts/presentation/pages/alerts_hub_page.dart` | 448 | 293 | Extraer `AlertFiltersBar`, `AlertListView`, `AlertStatsSummary`. Mover `CrmRepository` a Provider. |
| `lib/features/devices/presentation/widgets/realtime_sensor_chart.dart` | 444 | 18 | Extraer `SensorLinePainter`, `TimeAxisWidget`. |
| `lib/features/intelligence/presentation/pages/intelligence_warnings_page.dart` | 440 | 67 | Extraer `WarningListItem`, `WarningSeverityBadge`. |
| `lib/features/devices/presentation/widgets/create_sensor_modal.dart` | 421 | 182 | Extraer `SensorFormFields`, `SensorTypeSelector`. |
| `lib/features/admin/users/presentation/pages/admin_users_page.dart` | 410 | 176 | Extraer `UserTableWidget`, `UserFilterBar`. |
| `lib/features/devices/presentation/pages/add_device_screen.dart` | 381 | 7 | Extraer `DeviceFormWidget`, `QrScanSection`. |
| `lib/features/crm/presentation/pages/crm_home_page.dart` | 381 | 49 | Extraer `CrmHomeHeader`, `CrmQuickActionsGrid`. |
| `lib/features/devices/presentation/pages/devices_clean_readings_page.dart` | 376 | 241 | Extraer `ReadingsTableWidget`, `ReadingsFilterBar`. |
| `lib/features/crm/presentation/pages/crm_account_page.dart` | 374 | 271 | Extraer `AccountProfileCard`, `AccountSubscriptionInfo`. |
| `lib/features/monitoring/presentation/pages/sensor_raw_diagnosis_page.dart` | 369 | 45 | Extraer `DiagnosisResultWidget`, `RawDataInspector`. |
| `lib/features/crm/presentation/pages/crm_devices_page.dart` | 355 | 124 | Extraer `DeviceTableWidget`, `DeviceStatusFilter`. |
| `lib/features/devices/presentation/pages/devices_list_page.dart` | 353 | 210 | Extraer `DeviceListItem`, `DeviceListFilters`. |
| `lib/core/notifications/notification_state_service.dart` | 342 | - | Este es un service, no widget. Refactorizar a BLoC o separar en `NotificationStateNotifier` + `NotificationRepository`. |
| `lib/features/devices/data/provisioning_repository.dart` | 331 | - | Separar en `ProvisioningConfigRepository`, `ProvisioningQrRepository`. |
| `lib/core/alerts/alert_snapshot_service.dart` | 324 | - | Separar logica de cache de logica de fetch. |
| `lib/features/auth/presentation/pages/login_page.dart` | 319 | 210 | Extraer `LoginFormWidget`, `LoginSocialButtons`. Mover `AuthRepository` a Provider. |
| `lib/features/monitoring/data/monitoring_repository.dart` | 312 | - | Es un "god repository" con muchas responsabilidades. Dividir en `SensorRepository`, `DeviceRepository`, `DashboardRepository`. |

---

## 2. Violaciones de patrones Flutter

| Archivo | Linea | Descripcion | Correccion sugerida |
|---|---|---|---|
| `lib/features/monitoring/presentation/pages/dashboard_page.dart` | ~220 | `setState` en page de 784 LOC que gestiona polling, repositorios y navegacion. | Extraer todo estado a `DashboardCubit` / `DashboardViewModel` con Provider/Riverpod. |
| `lib/features/devices/presentation/pages/sensor_detail_page.dart` | ~96, 149 | `setState` usado 11 veces en widget de 1733 LOC. Contiene logica de polling, requestGen, fetchInFlight. | Crear `SensorDetailCubit` que gestione el ciclo de vida del polling y exponga estados. |
| `lib/features/devices/presentation/widgets/define_sensor_flow.dart` | ~104 | `setState` 14 veces en wizard de 993 LOC. | Usar `PageController` + `ChangeNotifier` (`DefineSensorFlowController`) o `FormCubit`. |
| `lib/features/intelligence/presentation/pages/intelligence_health_page.dart` | ~66 | `setState` en pagina de 1308 LOC con multiples tabs y fetches. | Extraer estado por tab a `HealthTabCubit`, `PredictionsTabCubit`, etc. |
| `lib/features/devices/presentation/pages/device_detail_page.dart` | ~51 | `setState` en pagina de 637 LOC que instancia `MonitoringRepository` y `ProvisioningRepository`. | `DeviceDetailCubit` + inyeccion de repos via constructor/Provider. |
| `lib/features/crm/presentation/widgets/crm_dashboard_content.dart` | ~63, 106 | `setState` en widget de 870 LOC que usa `DashboardCacheService`, `MonitoringRepository`, `AlertsRepository`. | `CrmDashboardViewModel` con inyeccion de dependencias. |
| `lib/features/alerts/presentation/pages/alert_detail_page.dart` | ~67 | `setState` 8 veces en pagina de 598 LOC que maneja `Timer`, `MonitoringRepository`, `AlertSnapshotService`, `CrmRepository`. | `AlertDetailCubit`. Asegurar dispose del Timer. |
| `lib/features/devices/presentation/pages/devices_clean_readings_page.dart` | ~33 | `setState` 10 veces. Pagina de 376 LOC que mezcla tabla, filtros, fetches. | `CleanReadingsCubit`. |
| `lib/features/admin/users/presentation/pages/admin_users_page.dart` | ~33 | `setState` en tabla de usuarios con operaciones CRUD inline. | `AdminUsersCubit`. |
| `lib/features/crm/presentation/pages/crm_account_page.dart` | ~50 | `setState` con carga de datos de cuenta y suscripcion. | `AccountCubit`. |
| `lib/features/auth/presentation/pages/login_page.dart` | ~44 | `setState` 5 veces en pagina de 319 LOC con validacion inline y llamada a repo. | `LoginCubit` con form validation. |
| `lib/features/crm/presentation/widgets/notification_bell_widget.dart` | ~59 | `setState` en widget de 552 LOC que escucha `NotificationStateService` directamente. | Convertir a `Consumer<NotificationState>` o usar `StreamBuilder` con Provider. |
| `lib/features/alerts/presentation/widgets/frozen_alert_chart.dart` | - | `StatefulWidget` sin `setState` (podria ser `StatelessWidget`). | Convertir a `StatelessWidget`. |
| `lib/features/monitoring/presentation/pages/sensor_readings_page.dart` | - | `StatefulWidget` sin `setState`. | Convertir a `StatelessWidget`. |
| `lib/features/monitoring/presentation/pages/sensor_week_readings_page.dart` | - | `StatefulWidget` sin `setState`. | Convertir a `StatelessWidget`. |
| `lib/features/devices/presentation/pages/sensor_details_route_page.dart` | - | `StatefulWidget` sin `setState`. | Convertir a `StatelessWidget`. |
| `lib/features/devices/presentation/pages/sensor_detail_page.dart` | ~131, 147 | `!` forzado sin validacion previa en valores de mapas y nullable fields. | Usar `?.` o `if (x != null)` antes de desempaquetar. |
| `lib/features/monitoring/presentation/pages/dashboard_page.dart` | ~98, 206 | `!` forzado en modelos que vienen del backend. | Validar con `try-catch` o usar modelos con defaults. |
| `lib/features/crm/presentation/widgets/crm_dashboard_content.dart` | ~99, 105 | `!` forzado en datos de cache/dashboard. | Manejo defensivo de nulls. |
| `lib/features/devices/presentation/widgets/ml_enhanced_chart.dart` | ~152, 233 | `!` forzado en datos de prediccion ML. | Usar `?.` o early return con `if (prediction == null)`. |
| `lib/features/devices/presentation/widgets/optimized_realtime_chart.dart` | ~181, 189 | `!` forzado en datos de serie temporal. | Validar bounds antes de acceder. |
| `lib/features/devices/presentation/widgets/candlestick_chart.dart` | ~203, 228 | `!` forzado en datos OHLC. | Verificar lista no vacia antes de indexar. |
| `lib/features/alerts/presentation/widgets/frozen_alert_chart.dart` | ~28, 126 | `!` forzado en alert data y puntos del chart. | Validacion previa. |
| `lib/core/network/api_client.dart` | ~55 | `!` forzado en parsing de response. | Usar `as?` o `cast` seguro. |
| `lib/main.dart` | ~27, 47 | `!` forzado en config inicial (Firebase, prefs). | Usar `?.` o manejo de error con fallback. |
| `lib/features/admin/users/presentation/pages/admin_users_page.dart` | ~241 | Uso de `context` despues de `await` sin verificar `mounted`. | Anadir `if (!mounted) return;` antes de `Navigator` o `setState`. |
| `lib/features/crm/presentation/pages/crm_home_page.dart` | ~59 | Uso de `SchedulerBinding` sin verificar `mounted`. | Verificar `mounted` antes de cualquier operacion post-frame. |

---

## 3. Violaciones SOLID

### S - Responsabilidad Unica (SRP)

| Clase/Archivo | Impacto | Refactor sugerido |
|---|---|---|
| `lib/features/monitoring/data/monitoring_repository.dart` | God repository con >5 metodos async mezclando sensores, dispositivos, alertas y dashboard. | Dividir en `SensorRepository`, `DeviceRepository`, `AlertRepository`, `DashboardRepository`. |
| `lib/features/devices/data/provisioning_repository.dart` | Maneja QR, provision, configuracion y validacion. | Separar en `ProvisioningRepository`, `DeviceConfigRepository`, `QrRepository`. |
| `lib/core/alerts/alert_snapshot_service.dart` | Cache + fetch + transformacion de alertas en un solo service. | Separar `AlertCache`, `AlertFetcher`, `AlertTransformer`. |
| `lib/core/notifications/notification_state_service.dart` | State management + MQTT listeners + persistence. | Separar `NotificationStateNotifier`, `MqttNotificationListener`, `NotificationPersistence`. |
| `lib/features/devices/presentation/pages/sensor_detail_page.dart` | UI + polling + repos + formateo + navegacion. | Extraer `SensorDetailCubit` (estado), `SensorDetailNavigator` (navegacion), dejar solo UI en el widget. |
| `lib/features/monitoring/presentation/pages/dashboard_page.dart` | UI + polling + multiples repos + cache. | `DashboardCubit`, `DashboardNavigator`, widget solo presentacional. |
| `lib/features/crm/presentation/widgets/crm_dashboard_content.dart` | Widget + 3 repos + cache service + formateo. | `CrmDashboardViewModel` que orqueste repos; widget solo consume estado. |

### O - Abierto/Cerrado (OCP)

| Clase/Archivo | Impacto | Refactor sugerido |
|---|---|---|
| `lib/features/monitoring/presentation/pages/dashboard_page.dart` | Condicionales para cada rol (`if (role == UserRole.admin) ...`) dentro del build. | Usar `DashboardLayoutStrategy` con implementaciones por rol (`AdminDashboardLayout`, `OperatorDashboardLayout`, etc.) o `RoleBasedWidgetBuilder`. |
| `lib/core/utils/sensor_type_config.dart` | Mapas hardcodeados para tipo de sensor y unidades. | Extraer a clases de configuracion con `SensorType` como clase polimorfica o sealed class. |
| `lib/features/devices/presentation/pages/sensor_detail_page.dart` | Logica de modo (`realtime`, `frozenFromAlert`, `historical`) con if/else. | Usar `SensorDetailModeStrategy` con implementaciones concretas por modo. |

### L - Sustitucion de Liskov (LSP)

| Clase/Archivo | Impacto | Refactor sugerido |
|---|---|---|
| No se detectaron violaciones explicitas de herencia. El proyecto no usa subclases extensas de widgets custom. | - | - |

### I - Segregacion de Interfaces (ISP)

| Clase/Archivo | Impacto | Refactor sugerido |
|---|---|---|
| `lib/features/monitoring/data/models/monitoring_view_models.dart` | 975 LOC con decenas de clases acopladas. | Separar en archivos por dominio: `sensor_models.dart`, `device_models.dart`, `reading_models.dart`, `dashboard_models.dart`. |
| `lib/features/intelligence/data/intelligence_models.dart` | 892 LOC con modelos de prediccion, salud, decisiones. | Dividir en `prediction_models.dart`, `health_models.dart`, `decision_models.dart`. |
| `lib/features/crm/data/models/crm_devices_models.dart` | 204 LOC con multiples modelos de CRM. | Dividir en `crm_device_model.dart`, `crm_alert_model.dart`, `crm_account_model.dart`. |

### D - Inversion de Dependencias (DIP)

| Clase/Archivo | Impacto | Refactor sugerido |
|---|---|---|
| `lib/features/devices/presentation/pages/sensor_detail_page.dart` | Instancia `TelemetryRepository()` y `MonitoringRepository()` directamente en `initState`. | Inyectar via constructor o `Provider` / `GetIt`. |
| `lib/features/monitoring/presentation/pages/dashboard_page.dart` | Instancia `MonitoringRepository()`, `NotificationsRepository()`, `NotificationStateService()`. | Inyectar todas las dependencias. |
| `lib/features/crm/presentation/widgets/crm_dashboard_content.dart` | Instancia `DashboardCacheService()`, `MonitoringRepository()`, `AlertsRepository()`. | Inyectar via Provider/constructor. |
| `lib/features/crm/presentation/widgets/notification_bell_widget.dart` | Instancia `NotificationStateService()` dentro del widget. | Inyectar como `Provider<NotificationStateService>`. |
| `lib/features/auth/presentation/pages/login_page.dart` | Instancia `AuthRepository()` en el state. | Inyectar via Provider/constructor. |
| `lib/features/admin/users/presentation/pages/admin_users_page.dart` | Instancia `AdminUsersRepository()` en el state. | Inyectar via Provider/constructor. |
| `lib/features/devices/presentation/pages/add_device_screen.dart` | Instancia `ProvisioningRepository()` en el state. | Inyectar via Provider/constructor. |
| `lib/features/devices/presentation/widgets/create_sensor_modal.dart` | Instancia `ProvisioningRepository()`. | Inyectar via Provider/constructor. |
| `lib/features/devices/presentation/widgets/define_sensor_flow.dart` | Instancia `ProvisioningRepository()`. | Inyectar via Provider/constructor. |
| `lib/features/alerts/presentation/pages/alert_detail_page.dart` | Instancia `MonitoringRepository()`, `AlertSnapshotService()`, `CrmRepository()`. | Inyectar via Provider/constructor. |
| `lib/features/alerts/presentation/pages/alerts_hub_page.dart` | Instancia `CrmRepository()`. | Inyectar via Provider/constructor. |

---

## 4. Bugs detectados

| Severidad | Archivo | Linea | Descripcion | Correccion sugerida |
|---|---|---|---|---|
| 🔴 Critico | `lib/features/admin/users/presentation/pages/admin_users_page.dart` | ~241 | Uso de `context` despues de `await` sin verificar `mounted`. Si el usuario navega atras durante el await, el widget puede estar desmontado. | Anadir `if (!mounted) return;` inmediatamente despues del await. |
| 🔴 Critico | `lib/features/alerts/presentation/pages/alert_detail_page.dart` | - | Uso de `Timer` sin `dispose()`. Memory leak progresivo al navegar fuera de la pagina. | Implementar `dispose()` y llamar `timer?.cancel()`. |
| 🔴 Critico | `lib/features/alerts/presentation/widgets/frozen_alert_chart.dart` | - | Uso de `Timer` sin `dispose()`. El widget puede quedar escuchando indefinidamente. | Implementar `dispose()` con `timer?.cancel()`. |
| 🔴 Critico | `lib/features/devices/presentation/pages/sensor_thresholds_page.dart` | - | `TextEditingController` declarado pero sin `dispose()`. Memory leak. | Implementar `dispose()` y llamar `controller.dispose()`. |
| 🔴 Critico | `lib/features/devices/presentation/pages/sensor_detail_page.dart` | ~129 | `_poller = Timer.periodic(...)` se cancela en `dispose()`, pero `_fetchInFlight` no tiene cancelacion de token/future. | Usar `CancelableOperation` o verificar `_requestGen` antes de setState adicionalmente. |
| 🟡 Moderado | `lib/features/devices/presentation/pages/sensor_detail_page.dart` | ~367, 306 | Uso frecuente de `!` en valores que vienen del backend (`realtime.points.last.timestamp!`, `dashboard.metrics.currentValue!`). Si el backend cambia o hay lista vacia, crashea. | Validar null/empty antes de desempaquetar; usar defaults o estados de error. |
| 🟡 Moderado | `lib/features/monitoring/presentation/pages/dashboard_page.dart` | ~798, 799 | `!` forzado en mapas de datos del dashboard. | Usar `?.` o `if (data.containsKey(...))`. |
| 🟡 Moderado | `lib/features/crm/presentation/widgets/crm_dashboard_content.dart` | ~325, 761 | `!` forzado en modelos de cache y datos CRM. | Manejo defensivo de nulls con early returns. |
| 🟡 Moderado | `lib/features/devices/presentation/widgets/ml_enhanced_chart.dart` | ~675 | `!` forzado en datos de prediccion ML. Si el modelo no ha entrenado, la lista puede estar vacia. | Verificar `isNotEmpty` antes de `first!` / `last!`. |
| 🟡 Moderado | `lib/features/devices/presentation/widgets/optimized_realtime_chart.dart` | ~615 | `!` forzado en serie temporal. | Validar bounds e indices. |
| 🟡 Moderado | `lib/features/devices/presentation/widgets/realtime_sensor_chart.dart` | ~379 | `!` forzado en datos de sensor. | Validar null antes de acceder. |
| 🟡 Moderado | `lib/features/crm/presentation/pages/crm_device_history_page.dart` | ~209 | `!` forzado en parsing de fechas/historial. | Usar `DateTime.tryParse` y manejar null. |
| 🟡 Moderado | `lib/features/devices/presentation/widgets/candlestick_chart.dart` | ~203, 228 | `!` forzado en datos OHLC sin verificar que la lista tenga suficientes elementos. | Verificar `length >= index` antes de acceder. |
| 🟡 Moderado | `lib/core/network/api_client.dart` | ~55 | `!` en casting de response JSON. Si el backend devuelve un formato inesperado, crashea. | Usar `as? Map<String, dynamic>` y manejar el caso null. |
| 🟡 Moderado | `lib/main.dart` | ~27, 47 | `!` en inicializacion de Firebase y prefs. Si falla, la app no arranca controladamente. | Usar `?.` y mostrar pantalla de error. |
| 🟡 Moderado | `lib/features/monitoring/presentation/pages/sensor_raw_diagnosis_page.dart` | ~74, 87 | `!` forzado en datos de diagnostico. | Validar null. |
| 🟡 Moderado | `lib/features/devices/presentation/pages/devices_list_page.dart` | ~229, 311 | `!` forzado en propiedades de dispositivo. | Usar valores por defecto o `?.`. |
| 🟢 Menor | `lib/features/admin/users/presentation/pages/admin_users_page.dart` | - | `TextEditingController` sin `dispose()`. | Anadir `dispose()`. |
| 🟢 Menor | `lib/features/devices/presentation/pages/sensor_detail_page.dart` | - | `_requestGen` compartido entre `_loadInitial` y `_refresh` sin cancelacion de Future. | Usar `CancelableOperation` o verificar gen en cada await intermedio. |
| 🟢 Menor | `lib/core/realtime/realtime_chart_controller.dart` | - | `AnimationController` potencial sin dispose (si existe). | Revisar y anadir `dispose()`. |
| 🟢 Menor | `lib/core/realtime/mqtt_telemetry_service.dart` | - | `StreamSubscription` potencial sin cancel. | Revisar y anadir `cancel()` en dispose. |
| 🟢 Menor | `lib/core/realtime/realtime_service.dart` | - | `StreamSubscription` y `Timer` potenciales sin cancel. | Revisar lifecycle y anadir cleanup. |
| 🟢 Menor | `lib/core/cache/dashboard_cache_service.dart` | ~64 | `!` forzado en cache hits. | Usar `?.` o `if (cached != null)`. |

---

## 5. Mejoras de diseno y UX

- **Estructura de carpetas:** El proyecto no usa BLoC / ViewModel. Se recomienda crear una capa intermedia:
  - `lib/features/X/presentation/blocs/` o `view_models/` para cada feature.
  - `lib/features/X/domain/` para use cases (opcional si se escala).
- **Naming consistency:** Algunos archivos usan `_page.dart`, otros `_screen.dart`, otros `_page.dart` con widgets internos. Unificar a `_page.dart` para rutas y `_widget.dart` para componentes reutilizables.
- **DashboardTextStyles:** Se usa en 34 archivos. Es un archivo centralizado (`dashboard_styles.dart`) pero con nombre muy especifico. Considerar renombrar a `app_text_styles.dart` o dividir en `theme/text_styles.dart` y `theme/colors.dart`.
- **Duplicacion de codigo:** Patron de `Row(children: [Icon(...), SizedBox(width: 8), Text(...)])` repetido en decenas de lugares. Extraer a `LabeledIcon` widget.
- **Patron de tarjeta con titulo + contenido:** Repetido en casi todas las pages. Extraer a `DashboardCard(title, child)`.
- **Accesibilidad:** No se detectaron `Semantics` labels ni descriptions. Los iconos actionables no tienen `tooltip` consistente.
- **Responsive:** El codigo asume ancho fijo en muchos lugares (e.g. `SizedBox(width: 8)`, `fontSize: 34` sin `MediaQuery`).
- **Magic numbers:** Valores como `14`, `34`, `120`, `15` (segundos de polling) estan hardcodeados. Extraer a constants.

---

## 6. Plan de refactor recomendado (sin regresiones)

### Paso 1 — Micro-refactors seguros (semana 1)
1. Convertir `StatefulWidget` sin `setState` a `StatelessWidget`.
   - Archivos: `frozen_alert_chart.dart`, `sensor_readings_page.dart`, `sensor_week_readings_page.dart`, `sensor_details_route_page.dart`.
   - **Validar:** Compilacion limpia, navegacion a estas pantallas funciona.
2. Anadir `dispose()` faltantes para `Timer`, `TextEditingController`.
   - Archivos: `alert_detail_page.dart`, `frozen_alert_chart.dart`, `sensor_thresholds_page.dart`, `admin_users_page.dart`.
   - **Validar:** Memory profile con Flutter DevTools; verificar que no haya leak de timers al salir de la pantalla.
3. Anadir `if (!mounted) return;` despues de cada `await` que use `context`.
   - Archivos: `admin_users_page.dart`, `sensor_detail_page.dart`, `crm_home_page.dart`.
   - **Validar:** Tests manuales de navegacion rapida (pop durante loading).

### Paso 2 — Extraccion de widgets presentacionales (semana 1-2)
1. Extraer `DashboardCard`, `LabeledIcon`, `StatusChip` reutilizables.
2. Extraer widgets de los build() mas largos (sin mover logica de estado):
   - `sensor_detail_page.dart`: `_buildMetricsCard`, `_buildChartArea`.
   - `dashboard_page.dart`: `DashboardHeader`, `DashboardGrid`.
   - `intelligence_health_page.dart`: `HealthTabContent`.
   - `frozen_alert_chart.dart`: `FrozenChartCanvas`.
   - **Validar:** UI pixel-perfect comparando screenshots antes/después.

### Paso 3 — Inyeccion de dependencias (semana 2)
1. Instalar `provider` o `flutter_bloc`.
2. Registrar repositorios como singletons en un `MultiProvider` en `main.dart`.
3. Reemplazar instanciacion inline (`Repository()`) por `context.read<Repo>()` en widgets grandes.
   - Empezar por `dashboard_page.dart`, `sensor_detail_page.dart`, `alert_detail_page.dart`.
   - **Validar:** Todos los flujos de carga de datos siguen funcionando; verificar que no haya doble instanciacion de repos.

### Paso 4 — ViewModels / Cubits (semana 2-3)
1. Para cada page con `setState` + logica de fetch/polling, crear un `Cubit`:
   - `DashboardCubit`, `SensorDetailCubit`, `AlertDetailCubit`, `AdminUsersCubit`, `LoginCubit`.
2. Migrar `setState` a emision de estados del Cubit.
3. Mantener los widgets como `StatelessWidget` o `BlocBuilder`.
   - **Validar:** Testear cada flujo completo (login, carga de dashboard, navegacion a sensor, polling, alertas).

### Paso 5 — Division de repositorios y modelos (semana 3-4)
1. Dividir `monitoring_repository.dart` en repos especializados.
2. Dividir `monitoring_view_models.dart` y `intelligence_models.dart` en archivos por dominio.
3. Mover logica de parsing/formato de los widgets a los ViewModels o a extensiones de modelo.
   - **Validar:** Compilacion limpia, todas las llamadas API siguen funcionando (verificar con integration tests o manualmente).

### Paso 6 — Null-safety defensiva (semana 4)
1. Revisar todos los `!` marcados en la auditoria.
2. Reemplazar con validaciones previas o modelos con campos no-nullable.
   - **Validar:** Static analysis (`flutter analyze`) sin warnings; testear con datos vacios del backend.

---

## Decisiones requeridas

⚠️ **DECISION REQUERIDA:** Seleccionar framework de estado: `flutter_bloc`, `Riverpod`, `MobX` o continuar con `setState` + `ChangeNotifier`?
- Recomendacion: `flutter_bloc` o `Riverpod` dada la escala (>30 widgets con estado propio).

⚠️ **DECISION REQUERIDA:** Estrategia de inyeccion de dependencias: `Provider`, `GetIt`, o constructor injection manual?
- Recomendacion: `Provider` + `RepositoryProvider` para mantener dependencia declarativa en el arbol de widgets.

⚠️ **DECISION REQUERIDA:** Los modelos actuales usan `DateTime?` y `double?` extensivamente. Migrar a campos no-nullable con defaults o mantener nullable con manejo defensivo?
- Recomendacion: Usar `freezed` + `json_serializable` para generar modelos inmutables y seguros.
