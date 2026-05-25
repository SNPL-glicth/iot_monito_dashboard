# 📡 IoT Monitor Dashboard

> **Dashboard / CRM de monitoreo IoT** construido en Flutter.  
> Visualización en tiempo real, alertas inteligentes y diagnóstico de modelos ML — todo en una sola app.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Backend](https://img.shields.io/badge/Backend-NestJS-E0234E?logo=nestjs)

---

## Tabla de contenidos

1. [¿Qué hace este proyecto?](#-qué-hace-este-proyecto)
2. [Requisitos previos](#-requisitos-previos)
3. [Instalación y ejecución](#-instalación-y-ejecución)
4. [Configuración del backend](#-configuración-del-backend)
5. [Roles de usuario](#-roles-de-usuario)
6. [Flujo del aplicativo](#-flujo-del-aplicativo)
7. [Arquitectura del código](#-arquitectura-del-código)
8. [Endpoints esperados](#-endpoints-esperados)
9. [Funcionalidades principales](#-funcionalidades-principales)
10. [Problemas comunes](#-problemas-comunes)

---

## 🎯 ¿Qué hace este proyecto?

Frontend Flutter para un sistema de monitoreo IoT con capacidades de CRM. Sus funciones principales son:

- **Monitoreo en tiempo real** de dispositivos y sensores vía polling ligero (~3s)
- **Sistema de alertas inteligente** con deduplicación y filtros ML
- **Gráficas interactivas** estilo trading con zoom, pan y resaltado de puntos
- **Diagnóstico del modelo ML** con métricas de salud, error y precisión
- **Gestión de usuarios** con tres niveles de acceso (admin / operador / supervisor)
- **Autenticación JWT** con refresh automático 3 horas antes de expirar

---

## ✅ Requisitos previos

- **Flutter SDK** instalado y en el PATH
- **Backend NestJS** levantado (por defecto en el puerto `3000`)

> ⚠️ Este proyecto **no incluye un mock server**. Si el backend no está disponible, verás errores en las pantallas que consumen la API.

---

## 🚀 Instalación y ejecución

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ver dispositivos disponibles
flutter devices

# 3. Ejecutar (dispositivo por defecto)
flutter run

# 3b. Ejecutar en Web (Chrome)
flutter run -d chrome
```

---

## ⚙️ Configuración del backend

La URL base se define en `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';
}
```

| Entorno | URL recomendada |
|---|---|
| Emulador Android | `http://10.0.2.2:3000` |
| Web / Desktop / macOS / Windows | `http://localhost:3000` |
| Celular físico (misma red) | `http://192.168.x.x:3000` |

---

## 👥 Roles de usuario

La app maneja 3 roles que deben coincidir con los que devuelve el backend:

| Rol | Clave | Acceso |
|---|---|---|
| Administrador | `admin` | Acceso completo + gestión de usuarios |
| Operador | `operator` | Dashboard + dispositivos + alertas |
| Supervisor | `viewer` | Solo lectura |

---

## 🗺️ Flujo del aplicativo

### 1. Arranque

- Punto de entrada: `lib/main.dart`
- La app inicia directamente en `LoginPage`
- Tema global: oscuro, Material 3

---

### 2. Login

**Pantalla:** `lib/features/auth/presentation/pages/login_page.dart`

```
Usuario ingresa credenciales
        ↓
POST /auth/login-token
        ↓
JWT guardado en ApiClient.authToken (memoria)
Usuario guardado en CurrentUser.value
        ↓
Redirección según rol
```

> ⚠️ El token **no se persiste** entre sesiones. Si cierras la app, deberás iniciar sesión nuevamente.

---

### 3. Home principal — Shell CRM

**Pantalla:** `lib/features/crm/presentation/pages/crm_home_page.dart`

Incluye:
- AppBar con chip de rol y campanita de eventos ML
- Drawer de navegación lateral
- Contenido principal: `CrmDashboardContent` (polling a `/crm/dashboard` sin `RefreshIndicator`)

---

### 4. Navegación desde el Drawer

| Opción | Roles | Destino | Endpoint |
|---|---|---|---|
| Dashboard | Todos | `CrmDashboardContent` | `GET /crm/dashboard` |
| Dispositivos | admin | `DevicesHubPage` | `GET /crm/devices` |
| Dispositivos | operator / viewer | `CrmDevicesPage` | `GET /crm/devices` |
| Alertas | Todos | *(próximamente)* | — |
| Configuraciones | admin | `AdminPanelPage` | `GET /admin/users` |
| Cuenta | Todos | `CrmAccountPage` | `GET /auth/me` |
| Cerrar sesión | Todos | Limpia token → `LoginPage` | — |

---

### 5. Flujo de Dispositivos

```
CrmDevicesPage  →  tap   →  CrmDeviceTypePage   (agrupa por tipo)
                →  long  →  CrmDeviceDetailsPage (perfil completo)
```

**Endpoint de perfil completo:** `GET /crm/devices/:id/profile-full`  
Incluye: resumen, KPIs, sensores (serie/estadísticos), alertas (activas / ack).

---

### 6. Administración (solo admin)

**Ruta:** Drawer → Configuraciones → `AdminPanelPage`

| Acción | Endpoint |
|---|---|
| Listar usuarios | `GET /admin/users` |
| Crear usuario | `POST /admin/users` |
| Editar usuario | `PUT /admin/users/:id` |
| Eliminar usuario | `DELETE /admin/users/:id` |

> En el panel de creación/edición solo se muestran los 3 roles disponibles: `admin`, `operator`, `viewer`.

---

## 🏗️ Arquitectura del código

```
lib/
├── core/
│   ├── config/
│   │   └── api_config.dart        # URL base del backend
│   ├── network/
│   │   └── api_client.dart        # Cliente HTTP + header Authorization
│   └── auth/
│       ├── current_user.dart      # Usuario en memoria
│       └── user_role.dart         # Enum de roles
│
└── features/
    ├── auth/                      # Login
    ├── crm/                       # Dashboard CRM + dispositivos + cuenta
    ├── admin/                     # Gestión de usuarios
    ├── devices/                   # Hub de dispositivos (navegación por categorías)
    ├── alerts/                    # Hub de alertas (placeholder)
    ├── monitoring/                # Endpoints históricos / dashboard legacy
    ├── operator/                  # Dashboard alternativo (placeholder)
    └── viewer/                    # Dashboard alternativo (placeholder)
```

---

## 🔌 Endpoints esperados

### Autenticación
| Método | Ruta |
|---|---|
| `POST` | `/auth/login-token` |
| `GET` | `/auth/me` |

### CRM
| Método | Ruta |
|---|---|
| `GET` | `/crm/dashboard` |
| `GET` | `/crm/devices?page=&pageSize=&q=&status=&type=` |
| `GET` | `/crm/devices/:id/profile-full` |

### Administración
| Método | Ruta |
|---|---|
| `GET` | `/admin/users` |
| `POST` | `/admin/users` |
| `PUT` | `/admin/users/:id` |
| `DELETE` | `/admin/users/:id` |

### Monitoreo e Inteligencia
| Método | Ruta |
|---|---|
| `GET` | `/monitoring/devices` |
| `GET` | `/monitoring/readings/latest` |
| `GET` | `/monitoring/alerts/active` |
| `GET` | `/monitoring/predictions` |
| `GET` | `/monitoring/ml-events/active` |
| `GET` | `/notifications/unread` |
| `GET` | `/intelligence/ml/diagnostic` |

---

## ✨ Funcionalidades principales

### Gráficas interactivas

| Feature | Archivo | Descripción |
|---|---|---|
| Gráfica estilo trading | `candlestick_chart.dart` | Zoom, pan y fondo oscuro |
| Ventana de última hora | `candlestick_chart.dart` | Solo muestra datos recientes |
| Modo solo-alertas | `candlestick_chart.dart` | Gráfica vacía cuando no hay alertas activas |
| Controles de zoom | `candlestick_chart.dart` | Botones +/− y reset |
| Punto resaltado | `candlestick_chart.dart` | Resalta el punto al hacer click en una notificación |
| Historial de alertas | `sensor_detail_page.dart` | Lista de últimas 20 alertas/warnings |

### Sistema de notificaciones

| Feature | Archivo | Descripción |
|---|---|---|
| Deduplicación | `notifications_repository.dart` | Agrupa duplicados con contador |
| Filtro ML (máx 2) | `notifications_repository.dart` | Máximo 2 notificaciones ML por sensor |
| Botón limpiar | `dashboard_page.dart` | Elimina todas las notificaciones |
| Contador de ocurrencias | `dashboard_page.dart` | Muestra "×3" si se repite 3 veces |
| Navegación con resaltado | `dashboard_page.dart` | Click en notificación → gráfica con punto resaltado |

### Diagnóstico del modelo ML

**Pantalla:** `intelligence_health_page.dart` — **Endpoint:** `GET /intelligence/ml/diagnostic`

| Métrica | Descripción |
|---|---|
| Health Score | Puntuación 0–100 del estado del modelo |
| Errores (MAE, RMSE, MAPE, σ) | Métricas de error del modelo |
| Calidad de predicciones | Confianza promedio y distribución por rangos |
| Precisión por umbral | % de predicciones dentro de ±5%, ±10%, ±20% |
| Actividad | Predicciones por hora / día / semana |
| Anomalías | Total detectadas y tasa de detección |
| Advertencias | Alertas del sistema y recomendaciones |

> **Nota:** Esta sección expone métricas **agregadas** del modelo ML, no predicciones individuales. Cumple con ISO 27001 al no exponer datos sensibles.

### Autenticación

| Feature | Archivo | Descripción |
|---|---|---|
| Token refresh automático | `token_manager.dart` | Refresh 3 horas antes de expirar |
| Decodificación JWT | `token_manager.dart` | Extrae fecha de expiración del token |

---

## 🐛 Problemas comunes

| Síntoma | Causa probable | Solución |
|---|---|---|
| Pantallas en blanco | Backend no disponible o URL incorrecta | Verificar `ApiConfig.baseUrl` y que el servidor esté levantado |
| Errores de CORS en Web | Configuración del servidor | Resolver CORS del lado del backend |
| Error 401 / 403 | Credenciales inválidas o token expirado | Cerrar sesión y volver a autenticarse |
| Sesión perdida al reiniciar | El token no se persiste | Comportamiento esperado — volver a hacer login |

