# CHANGELOG-UX — Mejoras Transversales de UX y Rendimiento

## Sesión: 2026-05-25

---

### 1. Gestor Global de Errores de Red (Interceptor)

**Archivos nuevos:**
- `lib/core/network/api_error_interceptor.dart`
  - Singleton `ApiErrorInterceptor` que captura errores 401, 403, 500 y timeouts provenientes de `ApiClient`.
  - **401/403**: Limpia sesión (`AuthStorage.clearSession()`, `ApiClient.authToken = null`, `TokenManager.stopMonitoring()`) y emite `UnauthorizedEvent` a un stream broadcast.
  - **500/timeout**: Muestra un `MaterialBanner` no intrusivo en la parte superior con opciones de reintentar o ignorar.
  - Usa `GlobalKey<ScaffoldMessengerState>` (`rootScaffoldMessengerKey`) inyectado desde `main.dart` para mostrar banners sin depender de contexto.

**Archivos modificados:**
- `lib/core/network/api_client.dart`
  - Agregado método estático `_throwIntercepted()` que invoca `ApiErrorInterceptor().handle(error)` antes de relanzar la excepción.
  - Todas las excepciones (`ApiException`, `ApiTimeoutException`) ahora pasan por el interceptor.
- `lib/core/bootstrap/app_bootstrapper.dart`
  - Se suscribe a `ApiErrorInterceptor().onUnauthorized`; al recibir un evento limpia sesión, muestra `SnackBar` explicativo y redirige al login.
- `lib/main.dart`
  - Crea `rootScaffoldMessengerKey` y lo pasa al `MaterialApp`.
  - Registra `ApiErrorInterceptor().attachScaffoldMessengerKey(...)` en startup.

---

### 2. Control Global de AppLifecycle para Todos los Pollings

**Archivos nuevos:**
- `lib/core/lifecycle/app_lifecycle_service.dart`
  - Singleton `AppLifecycleService` que implementa un único `WidgetsBindingObserver`.
  - Emite streams `onAppPaused` y `onAppResumed` para que cualquier módulo se suscriba sin implementar su propio observer.
  - Expone `bool isAppActive` para lectura síncrona del estado actual.

**Archivos modificados (reemplazo de polling propio por suscripción centralizada):**
- `lib/features/crm/presentation/widgets/crm_dashboard_content.dart`
  - Eliminado `WidgetsBindingObserver` mixin y `didChangeAppLifecycleState`.
  - Polling ahora pausa/reanuda vía `AppLifecycleService` streams.
- `lib/features/metrics/presentation/pages/server_metrics_page.dart`
  - Polling de métricas centralizado; timer se cancela en pausa y se reinicia en resume.
- `lib/features/monitoring/presentation/pages/sensor_raw_diagnosis_page.dart`
  - Polling de diagnóstico centralizado.
- `lib/features/monitoring/presentation/pages/dashboard_page.dart`
  - Polling de dispositivos y `NotificationStateService` pausan/reanudan conjuntamente.
- `lib/features/devices/presentation/pages/sensor_detail_page.dart`
  - Polling de detalle de sensor centralizado (solo en modo realtime).
- `lib/features/intelligence/presentation/pages/intelligence_health_page.dart`
  - Polling de ML features centralizado.
- `lib/features/monitoring/presentation/cubit/dashboard_cubit.dart`
  - `startPolling`/`stopPolling` ahora escuchan `AppLifecycleService` en el constructor y `close()`.
- `lib/core/notifications/notification_state_service.dart`
  - Agregado `_setupLifecycleAwareness()` que detiene/inicia polling de notificaciones según estado de app.

---

### 3. Loading States Consistentes

**Archivos nuevos:**
- `lib/core/presentation/widgets/app_loading_widget.dart`
  - `AppLoadingWidget`: `CircularProgressIndicator` estandarizado con color primario del tema y mensaje opcional.
- `lib/core/presentation/widgets/app_skeleton_card.dart`
  - `AppSkeletonCard` y `AppSkeletonLine`: contenedores skeleton reutilizables con colores del dashboard.
- `lib/core/presentation/widgets/loading_overlay.dart`
  - `LoadingOverlay`: Stack con fondo semitransparente e indicador centrado para operaciones bloqueantes de pantalla completa.

**Archivos modificados (adopción de widgets estándar):**
- `lib/features/intelligence/presentation/pages/intelligence_health_page.dart`
  - Reemplazado `LoadingStateWidget` local por `AppLoadingWidget(message: '...')`.
  - Eliminado import de `loading_state_widget.dart`.
- `lib/core/bootstrap/app_bootstrapper.dart`
  - Splash screen usa `AppLoadingWidget` en lugar de `CircularProgressIndicator` aislado.
- `lib/features/metrics/presentation/pages/server_metrics_page.dart`
  - Estado de carga usa `AppLoadingWidget`.
- `lib/features/monitoring/presentation/pages/sensor_raw_diagnosis_page.dart`
  - Estado de carga usa `AppLoadingWidget`.

---

### 4. Transiciones de Navegación Consistentes

**Archivos nuevos:**
- `lib/core/navigation/app_transitions.dart`
  - `FadePageRoute`: transición de fade de 250ms (`Curves.easeInOut`).
  - `SlidePageRoute`: transición de slide desde la derecha de 300ms (`Curves.easeInOut`).

**Archivos modificados:**
- `lib/core/navigation/app_router.dart`
  - Reemplazados todos los `MaterialPageRoute` por `FadePageRoute` (rutas simples) o `SlidePageRoute` (rutas dinámicas con parámetros).
  - Eliminada inconsistencia entre defaults del router y transiciones custom.

---

### Resumen de Archivos Modificados/Creados

| Archivo | Cambio |
|---|---|
| `lib/core/network/api_error_interceptor.dart` | **Nuevo** — Interceptor global de errores de red |
| `lib/core/lifecycle/app_lifecycle_service.dart` | **Nuevo** — Singleton centralizado de AppLifecycle |
| `lib/core/presentation/widgets/app_loading_widget.dart` | **Nuevo** — Loading widget estándar |
| `lib/core/presentation/widgets/app_skeleton_card.dart` | **Nuevo** — Skeleton widgets estándar |
| `lib/core/presentation/widgets/loading_overlay.dart` | **Nuevo** — Overlay de pantalla completa |
| `lib/core/navigation/app_transitions.dart` | **Nuevo** — Transiciones Fade y Slide |
| `lib/main.dart` | Registro de `scaffoldMessengerKey`, `AppLifecycleService.attach()`, `ApiErrorInterceptor` setup |
| `lib/core/network/api_client.dart` | Integración del interceptor vía `_throwIntercepted()` |
| `lib/core/bootstrap/app_bootstrapper.dart` | Suscripción a eventos 401 + uso de `AppLoadingWidget` |
| `lib/core/navigation/app_router.dart` | Uso de `FadePageRoute` / `SlidePageRoute` |
| `lib/core/notifications/notification_state_service.dart` | `_setupLifecycleAwareness()` para pausar/resumir polling |
| `lib/features/crm/presentation/widgets/crm_dashboard_content.dart` | Eliminado `WidgetsBindingObserver`; usa `AppLifecycleService` |
| `lib/features/metrics/presentation/pages/server_metrics_page.dart` | Polling lifecycle-aware + `AppLoadingWidget` |
| `lib/features/monitoring/presentation/pages/sensor_raw_diagnosis_page.dart` | Polling lifecycle-aware + `AppLoadingWidget` |
| `lib/features/monitoring/presentation/pages/dashboard_page.dart` | Polling y notification service lifecycle-aware |
| `lib/features/devices/presentation/pages/sensor_detail_page.dart` | Polling lifecycle-aware |
| `lib/features/intelligence/presentation/pages/intelligence_health_page.dart` | Polling lifecycle-aware + `AppLoadingWidget` |
| `lib/features/monitoring/presentation/cubit/dashboard_cubit.dart` | Polling lifecycle-aware en Cubit |

### Verificación

- `flutter analyze` ejecutado exitosamente: **No issues found**.
