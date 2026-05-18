# iot_monito_dashboard

Frontend Flutter para el **dashboard/CRM de monitoreo IoT**.

El objetivo de este README es que cualquier persona pueda entender rápidamente:

- qué hace el proyecto
- cómo se ejecuta
- cuál es el **flujo del aplicativo** (de login → navegación → consumo de API)

---

## Estado actual (enero 2026)

### Fixes y Features (Enero 2026)

#### Gráficas Rediseñadas
| Feature | Archivo | Descripción |
|---------|---------|-------------|
| **Nueva gráfica IQ Option** | `candlestick_chart.dart` | Estilo trading con zoom, pan, y fondo oscuro |
| **Ventana última hora** | `candlestick_chart.dart` | Solo muestra datos de la última hora |
| **Modo solo-alertas** | `candlestick_chart.dart` | Gráfica vacía cuando no hay alertas activas |
| **Controles de zoom** | `candlestick_chart.dart` | Botones +/- y reset para zoom |
| **Punto resaltado** | `candlestick_chart.dart` | Resalta punto desde click en notificación |
| **Historial de alertas** | `sensor_detail_page.dart` | Lista de últimas 20 alertas/warnings |

#### Sistema de Notificaciones Inteligente
| Feature | Archivo | Descripción |
|---------|---------|-------------|
| **Deduplicación** | `notifications_repository.dart` | Agrupa notificaciones duplicadas con contador |
| **Filtro ML (máx 2)** | `notifications_repository.dart` | Máximo 2 notificaciones ML por sensor |
| **Botón limpiar** | `dashboard_page.dart` | Elimina todas las notificaciones |
| **Contador ocurrencias** | `dashboard_page.dart` | Muestra "x3" si se repite 3 veces |
| **Navegación con resaltado** | `dashboard_page.dart` | Click en notificación → gráfica con punto resaltado |

#### Estado del Modelo ML (Diagnóstico Detallado)
| Feature | Archivo | Descripción |
|---------|---------|-------------|
| **Health Score** | `intelligence_health_page.dart` | Puntuación 0-100 del estado del modelo |
| **Métricas de Error** | `intelligence_health_page.dart` | MAE, RMSE, MAPE, Desviación Estándar |
| **Calidad de Predicciones** | `intelligence_health_page.dart` | Confianza promedio, distribución por rangos |
| **Precisión por Umbral** | `intelligence_health_page.dart` | % de predicciones dentro de ±5%, ±10%, ±20% |
| **Actividad del Modelo** | `intelligence_health_page.dart` | Predicciones por hora/día/semana |
| **Detección de Anomalías** | `intelligence_health_page.dart` | Total anomalías y tasa de detección |
| **Advertencias y Recomendaciones** | `intelligence_health_page.dart` | Alertas del sistema y sugerencias |

> **Nota importante**: La sección "Estado del Modelo" en el Drawer muestra métricas agregadas del modelo ML, **NO predicciones individuales**. Esta vista está diseñada para monitorear la salud y calidad del sistema de Machine Learning.

**Endpoint consumido**: `GET /intelligence/ml/diagnostic`

**ISO 27001**: Solo expone métricas agregadas, no datos sensibles.

#### Autenticación
| Feature | Archivo | Descripción |
|---------|---------|-------------|
| **Token refresh automático** | `token_manager.dart` | Refresh 3 horas antes de expirar |
| **Decodificación JWT** | `token_manager.dart` | Extrae fecha de expiración del token |

#### Fixes Anteriores
| Issue | Archivo | Solución |
|-------|---------|----------|
| **RangeError crash en gráficas** | `raw_readings_chart.dart` | Validación estricta de índices en `getTitlesWidget` |
| **Gráfica no renderiza** | `sensor_detail_page.dart` | `SizedBox(height: 260)` en lugar de `Expanded` |
| **Firebase no inicializa** | `main.dart` | Pasar `DefaultFirebaseOptions.currentPlatform` |
| **174 frames saltados** | `dashboard_page.dart` | Solo `setState` si hay cambios reales |
| **Warnings de locale** | `main.dart`, `pubspec.yaml` | Agregar `flutter_localizations` |

---

## Estado anterior (diciembre 2025)
- Dashboard muestra el título **IoT System**.
- Pantalla de **Detalle de sensor** (`SensorDetailPage`):
  - Sin redundancias (título/tarjetas ajustadas).
  - Sección **Lecturas del sensor** con accesos a **Día / Semana / Mes**.
  - **Semana**: vista tipo acordeón (Lun–Dom) con chip **HOY** en el día actual.
  - Para performance, en Semana se muestran **máximo 10 lecturas** por día y solo en rango **12:00–22:59**.
- Hora Colombia:
  - Se usa `NetworkClock` (intenta hora por internet para `America/Bogota` y hace fallback local) para calcular rangos Día/Semana/Mes.
- Separación en dashboard:
  - **Alertas** (operacionales) separadas de **Predicciones (ML)**.
  - En Predicciones (ML) existen **Predicciones** y **Advertencias (ML)**.
- Modelo de actualización (sin refresh manual):
  - El dashboard admin (`DashboardPage`) ya **no** tiene botón de "Refrescar" ni `RefreshIndicator`.
  - En su lugar, hace **polling ligero (≈3s)** a los endpoints de estado (`/monitoring/devices`, `/monitoring/readings/latest`, `/monitoring/predictions`, etc.) y a `GET /notifications/unread`.
  - La UI se comporta como un sistema IoT: **estado + eventos**, sin depender de acciones del usuario para actualizar información crítica.
- Campanita de notificaciones:
  - El AppBar del dashboard muestra una campanita con contador de notificaciones no leídas.
  - El contador se alimenta de `GET /notifications/unread` y se actualiza con el polling.
  - Al tocar la campanita, se navega al hub de alertas (`AlertsHubPage`).

## Requisitos previos

- Flutter SDK instalado.
- Backend NestJS levantado (por defecto la app apunta a un backend en el puerto `3000`).

> Nota: este frontend **no** incluye un mock server. Si el backend no está disponible, verás errores en las pantallas que consumen API.

---

## Instalación y ejecución

1) Instala dependencias:

```bash
flutter pub get
```

2) Ejecuta:

```bash
flutter run
```

Sugerencias útiles:

- Ver dispositivos disponibles:

```bash
flutter devices
```

- Ejecutar en Web:

```bash
flutter run -d chrome
```

---

## Configuración de la URL base del backend

La URL base se define en `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';
}
```

Casos típicos:

- **Emulador Android**: usar `http://10.0.2.2:3000` (mapea al `localhost` de tu PC).
- **Web / Desktop / Linux / Windows / macOS**: normalmente funciona `http://localhost:3000`.
- **Celular físico**: usar la IP local de tu PC, por ejemplo `http://192.168.1.50:3000`.

---

## Roles

La app maneja 3 roles (deben coincidir con lo que devuelve el backend):

- `admin` (Administrador)
- `operator` (Operador)
- `viewer` (Supervisor / solo lectura)

Nota de producto: en el **panel de administración de usuarios** solo se muestran estas 3 opciones de rol al crear/editar usuarios.

---

## Flujo del aplicativo (paso a paso)

### 1) Arranque

- Punto de entrada: `lib/main.dart`
- La app inicia en `LoginPage`.
- El tema global (oscuro, Material 3) también se define en `lib/main.dart`.

### 2) Login (autenticación)

Pantalla: `lib/features/auth/presentation/pages/login_page.dart`

- El usuario ingresa `username/email` + `password`.
- `AuthRepository` (`lib/features/auth/data/auth_repository.dart`) llama al backend:
  - `POST /auth/login-token`
- Si la respuesta es exitosa:
  - se guarda el JWT en memoria en `ApiClient.authToken` (variable estática)
  - se guarda el usuario actual en memoria en `CurrentUser.value`
  - se resuelve el rol (`admin/operator/viewer`)

> Importante: hoy el token **no se persiste** (no hay shared_preferences ni secure storage). Si cierras la app, se pierde la sesión.

### 3) Home principal (shell CRM)

Luego del login, la app navega a:

- `CrmHomePage` (`lib/features/crm/presentation/pages/crm_home_page.dart`)

Este “shell” incluye:

- AppBar con el rol (chip) y, si aplica, campanita de eventos ML.
- Drawer (menú lateral)
- Contenido principal del dashboard: `CrmDashboardContent` (usa snapshots de `/crm/dashboard` y endpoints de ML, sin `RefreshIndicator`).

### 4) Navegación desde el Drawer

En `CrmHomePage`, el Drawer permite:

- **Dashboard**
  - se mantiene en el dashboard principal CRM.
  - datos: `GET /crm/dashboard` (ver `CrmRepository.fetchDashboard`).

- **Dispositivos**
  - Si el rol es **admin**: abre `DevicesHubPage` (sección “Dispositivos” centralizada).
  - Si el rol es **operator/viewer**: abre `CrmDevicesPage` (listado paginado + detalle).

- **Alertas**
  - Actualmente aparece como “próximamente” desde el shell CRM.

- **Configuraciones** (solo `admin`)
  - Abre `AdminPanelPage` → “Gestionar usuarios”.

- **Cuenta**
  - Abre `CrmAccountPage`.
  - Muestra `CurrentUser.value` y si no existe intenta `GET /auth/me`.

- **Cerrar sesión**
  - Limpia `ApiClient.authToken` y `CurrentUser.value`.
  - Vuelve a `LoginPage`.

---

## Flujo de “Dispositivos” (CRM)

Pantallas principales:

- `CrmDevicesPage` → lista dispositivos (`GET /crm/devices?...`).
  - Tap: abre `CrmDeviceTypePage` (agrupa por tipo).
  - Long-press: abre detalle directo `CrmDeviceDetailsPage`.

- `CrmDeviceTypePage` → lista por tipo (`GET /crm/devices?type=...`).

- `CrmDeviceDetailsPage` → perfil completo del dispositivo:
  - `GET /crm/devices/:id/profile-full?...`
  - Muestra resumen, KPIs, sensores (serie/estadísticos) y alertas (activas/ack).

---

## Administración (solo admin)

- Entrada: Drawer → **Configuraciones**
- Pantalla: `AdminPanelPage` (`lib/features/admin/presentation/pages/admin_panel_page.dart`)
- Gestión de usuarios:
  - UI: `AdminUsersPage` y subpantallas
  - API: `AdminUsersRepository` (`lib/features/admin/users/data/admin_users_repository.dart`)
    - `GET /admin/users`
    - `POST /admin/users`
    - `PUT /admin/users/:id`
    - `DELETE /admin/users/:id`

---

## Arquitectura del código (cómo está organizado)

- `lib/core/`
  - `config/api_config.dart`: URL base del backend.
  - `network/api_client.dart`: cliente HTTP centralizado + cabecera `Authorization: Bearer <token>`.
  - `auth/current_user.dart`: usuario en memoria.
  - `auth/user_role.dart`: enum de roles.

- `lib/features/`
  - `auth/`: login.
  - `crm/`: dashboard CRM + dispositivos + cuenta.
  - `admin/`: pantallas de administración.
  - `devices/`: hub de dispositivos (orientado a navegación por categorías; parte está “próximamente”).
  - `alerts/`: hub de alertas (placeholder).
  - `monitoring/`: endpoints históricos/legacy (`/monitoring/*`) y dashboard admin legacy (`DashboardPage`).
  - `operator/` y `viewer/`: dashboards alternativos (placeholders/legacy).

---

## Endpoints esperados (resumen)

### Auth
- `POST /auth/login-token`
- `GET /auth/me`

### CRM
- `GET /crm/dashboard`
- `GET /crm/devices` (con `page`, `pageSize`, `q`, `status`, `type`)
- `GET /crm/devices/:id/profile-full`

### Admin (usuarios)
- `GET /admin/users`
- `POST /admin/users`
- `PUT /admin/users/:id`
- `DELETE /admin/users/:id`

### Monitoring / Inteligencia
- `GET /monitoring/devices`
- `GET /monitoring/readings/latest`
- `GET /monitoring/alerts/active`
- `GET /monitoring/predictions`
- `GET /monitoring/ml-events/active`
- `GET /notifications/unread`

---

## Problemas comunes

- **Pantallas en blanco o errores de red**: revisa `ApiConfig.baseUrl` y que el backend esté levantado.
- **En Web**: si hay problemas de CORS, deben resolverse del lado del backend.
- **403/401**: usuario/contraseña inválidos o token expirado/ausente (recuerda que el token solo vive en memoria).
