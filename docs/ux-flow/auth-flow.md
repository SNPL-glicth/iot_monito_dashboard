# Autenticación y Sesión — UX Flow

## Resumen del flujo

El módulo de autenticación gestiona el inicio de sesión, la persistencia de sesión y el cierre de sesión de la aplicación IoT Monitoring Dashboard. No existe un flujo de onboarding ni registro de nuevos usuarios desde la app; los usuarios son creados por un administrador desde el panel de admin. El punto de entrada único es `LoginPage`, que recoge credenciales y las valida contra el backend NestJS. Tras un login exitoso, el token JWT se almacena globalmente en `ApiClient.authToken` y se persiste mediante `AuthStorage` (`flutter_secure_storage` / `shared_preferences`). Si existe sesión persistida al arrancar la app, `AppBootstrapper` la restaura automáticamente y redirige al `CrmHomePage` correspondiente al rol del usuario.

## Pantallas involucradas

- **`LoginPage`** (`features/auth/presentation/pages/login_page.dart`): Formulario de inicio de sesión con usuario/contraseña.
- **`AppBootstrapper`** (`core/bootstrap/app_bootstrapper.dart`): Widget raíz que decide entre mostrar login o dashboard según sesión persistida.

## Flujo detallado

### LoginPage

#### Entrada
- **Desde**: `AppBootstrapper` cuando no hay sesión activa (`_role == null`).
- **Parámetros**: Ninguno; usa estado local (`TextEditingController`).
- **Autenticación**: Pública; no requiere token previo.

#### Acciones y cadena de llamadas

1. **Input de usuario/contraseña**
   - Widget: `TextFormField` (username y password).
   - Archivo: `@/home/nicolas/Documentos/Iot_System/iot_monito_dashboard/lib/features/auth/presentation/pages/login_page.dart:18-23`
   - Validación local: `_formKey.currentState!.validate()` requiere campos no vacíos (vía `validator` en `LoginFormWidgets`).

2. **Tap en "Iniciar sesión"**
   - Widget: `ElevatedButton` dentro del `Form`.
   - Archivo: `@/home/nicolas/Documentos/Iot_System/iot_monito_dashboard/lib/features/auth/presentation/pages/login_page.dart:43`
   - Función: `_submit()` (línea 43).
   - Cadena:
     - `LoginPage._submit()` → `AuthRepository.login(username, password)` → `ApiClient.postJsonAndDecode('/auth/login-token', body)`.
     - `AuthRepository` (`features/auth/data/auth_repository.dart`) parsea `access_token`, `refresh_token`, `role` y `user`.
     - Guarda token global: `ApiClient.authToken = token`.
     - Persiste sesión: `AuthStorage.saveSession(...)`.
     - Inicia monitoreo de token: `TokenManager().startMonitoring(token)`.
     - Conecta realtime: `RealtimeService().connect(authToken: token)`.

3. **Check "Mantener sesión iniciada" (`_rememberMe`)**
   - Widget: `CheckboxListTile` (implícito en el estado `_rememberMe`).
   - Lógica: Si es `true`, se persiste sesión; si es `false`, el token igual se guarda en `AuthStorage` (observado en código: `_authStorage.saveSession(...)` siempre se ejecuta; [PENDIENTE DE VERIFICAR] si hay condicional real).

#### Endpoints involucrados

| Endpoint | Método | Momento del llamado | Datos enviados | Respuesta esperada |
|----------|--------|---------------------|----------------|--------------------|
| `/auth/login-token` | POST | Tras validar formulario y setear `_isLoading = true` | `{username, password}` | `{access_token, refresh_token, role, user}` |

#### Estados visuales
- **Carga**: Circular progress overlay dentro del botón o pantalla completa (`_isLoading = true` → botón deshabilitado).
- **Error**: `_errorMessage` se muestra como texto debajo del formulario. Mensajes amigables mapeados desde códigos HTTP (401, 403, 5xx) en `AuthRepository.login()`.
- **Éxito**: Navegación inmediata a `CrmHomePage(role: result.role)` vía `pushReplacement`.

#### Salida / Navegación
- **pushReplacement** a `CrmHomePage` (línea 76).
- No hay opción de volver al login con `pop` desde el CRM; el login se elimina del stack.

### AppBootstrapper

#### Entrada
- Es el `home` de `MaterialApp` (`main.dart:36`).

#### Acciones y cadena de llamadas
1. **Inicialización post-frame**
   - `initState()` → `_bootstrap()`.
   - Intenta `AuthStorage.loadSession()` con timeout de 500ms.
   - Si hay sesión: restaura `ApiClient.authToken`, `_role`, `TokenManager`, `RealtimeService.connect()`.
   - Inicializa Firebase en background (`_initFirebaseInBackground`).

2. **Decisión de UI**
   - `_loading == true` → `CircularProgressIndicator`.
   - `_role != null` → `CrmHomePage(role: _role!)`.
   - Sin sesión → `LoginPage`.

#### Endpoints involucrados
- Ninguno directamente; solo lectura de almacenamiento local.

## Mapa de endpoints del módulo

| Endpoint | Método | Pantalla(s) que lo usan | Momento exacto del llamado | Dato crítico que retorna | Por qué se muestra en ese punto |
|----------|--------|------------------------|---------------------------|--------------------------|--------------------------------|
| `/auth/login-token` | POST | `LoginPage` | Tras submit del formulario válido | `access_token`, `role` | Decide a qué dashboard navegar y autoriza futuras llamadas |

## Diagnóstico UX

- 🟡 **Mejora**: El checkbox "Mantener sesión iniciada" parece redundante porque `_authStorage.saveSession()` se llama independientemente del valor de `_rememberMe`.
- 🟡 **Mejora**: No hay feedback visual de "Validando credenciales..." distinto al `CircularProgressIndicator` genérico; podría mejorarse con skeleton del formulario.
- 🟢 **Optimización**: El timeout de 500ms en `loadSession()` es agresivo; en dispositivos lentos podría fallar silenciosamente y forzar re-login innecesario.
- 🔴 **Crítico**: `AppBootstrapper` no maneja errores de red al refrescar token ni al conectar `RealtimeService`; el usuario podría quedarse en `CrmHomePage` con token expirado sin saberlo.
