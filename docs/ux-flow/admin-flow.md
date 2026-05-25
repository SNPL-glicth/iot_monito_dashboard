# Administración del Sistema — UX Flow

## Resumen del flujo

El módulo de Administración está reservado exclusivamente para usuarios con rol `admin`. Desde `AdminPanelPage` se accede a la gestión de usuarios (`AdminUsersPage`) y a las métricas del servidor (`ServerMetricsPage`). La gestión de usuarios incluye listado, creación, edición, activación/desactivación y eliminación. El panel de métricas es solo lectura y consume el servidor de telemetría para mostrar estado de CPU, RAM, ingesta y base de datos en tiempo real.

## Pantallas involucradas

- **`AdminPanelPage`** (`features/admin/presentation/pages/admin_panel_page.dart`): Panel de acceso a administración (usuarios, métricas).
- **`AdminUsersPage`** (`features/admin/users/presentation/pages/admin_users_page.dart`): Lista de usuarios con búsqueda, creación, edición y eliminación.
- **`AdminUserDetailsPage`** (`features/admin/users/presentation/pages/admin_user_details_page.dart`): Detalle de un usuario con acciones rápidas.
- **`AdminUserEditPage`** (`features/admin/users/presentation/pages/admin_user_edit_page.dart`): Formulario de edición completa de usuario.
- **`ServerMetricsPage`** (`features/metrics/presentation/pages/server_metrics_page.dart`): Dashboard de métricas del sistema (solo lectura).

## Flujo detallado

### AdminPanelPage

#### Entrada
- Desde `CrmDrawer` → "Configuraciones" (solo admin).
- **Parámetros**: `UserRole currentRole`.

#### Acciones y cadena de llamadas
1. **Tap en "Gestión de usuarios"**
   - push `AdminUsersPage(currentRole: currentRole)`.
2. **Tap en "Métricas del Servidor"**
   - push `ServerMetricsPage()`.

#### Estados visuales
- Cards de opciones con iconos. Opciones deshabilitadas si `currentRole != UserRole.admin`.

#### Salida / Navegación
- push a `AdminUsersPage` o `ServerMetricsPage`.

### AdminUsersPage

#### Entrada
- Desde `AdminPanelPage`.
- **Parámetros**: `UserRole currentRole`.

#### Acciones y cadena de llamadas
1. **Carga inicial**
   - `initState()` → `_loadUsers(reset: true)` → `AdminUsersRepository.fetchUsers(page=1, pageSize=20)` → GET `/admin/users?page=1&pageSize=20`.
2. **Paginación / scroll infinito**
   - Scroll al 80% → `_loadMore()` → página siguiente (`page++`) sin recargar toda la lista.
   - Footer: `LinearProgressIndicator` mientras carga más; "Sin más usuarios" al final.
3. **Búsqueda**
   - Campo de texto en AppBar envía `q` al backend vía GET `/admin/users?q={term}` al presionar Enter.
   - No filtra en cliente; la búsqueda reinicia a página 1.
4. **Crear usuario**
   - FAB "+" → `showUserDialog(context, repository, user: null)`.
   - Al confirmar: `repository.createUser(...)` → POST `/admin/users`.
   - SnackBar "Usuario creado" y `_loadUsers(reset: true)`.
5. **Editar usuario**
   - Popup menú o detalle → push `AdminUserEditPage`.
   - `_save()` → PUT `/admin/users/{id}`.
   - SnackBar "Cambios guardados" y recarga de lista.
6. **Eliminar usuario**
   - Popup menú "Eliminar" → `showDeleteUserDialog` (con consecuencia visible) → confirmar → DELETE `/admin/users/{id}`.
   - SnackBar "Usuario eliminado" y remoción local del ítem sin recargar toda la lista.

#### Endpoints involucrados
- GET `/admin/users`
- POST `/admin/users`
- PUT `/admin/users/{id}`
- DELETE `/admin/users/{id}`

#### Estados visuales
- **Loading**: `CircularProgressIndicator` durante carga inicial; footer `LinearProgressIndicator` en carga incremental.
- **Error**: Columna con mensaje + botón "Reintentar".
- **Empty**: `Text('No hay usuarios registrados.')`.
- **Móvil**: `ListView.builder` con `_UserCard` + popup menú (editar / eliminar) + scroll infinito.
- **Desktop/Web**: `DataTable` horizontalmente scrolleable con acciones inline.
- **Creación/Edición**: `AlertDialog` con campos de formulario y validación básica.
- **Feedback**: `SnackBar` verde tras crear/editar/eliminar; `SnackBar` rojo si el backend responde con error.

#### Salida / Navegación
- push a `AdminUserDetailsPage` o `AdminUserEditPage`.
- pop con resultado (`updated` o `true`) para forzar recarga en lista.

### AdminUserDetailsPage

#### Entrada
- Desde `AdminUsersPage` al tocar un usuario.
- **Parámetros**: `AdminUser user`, `UserRole currentRole`.

#### Acciones y cadena de llamadas
1. **Editar**
   - `_editUser()` → push `AdminUserEditPage` → espera resultado.
   - Si `updated != null`, actualiza `_user` local y hace `pop(context, true)` para forzar recarga en lista padre.
2. **Eliminar**
   - `_confirmDelete()` → `showDeleteUserDialog` (con consecuencia visible) → confirmar → `repository.deleteUser(_user.id)` → `pop(context, true)`.
   - Si falla: `SnackBar` de error. Si éxito: `SnackBar` de confirmación en la lista padre.

#### Estados visuales
- Vista de detalle con datos del usuario, rol, estado activo/inactivo.
- Botones de acción condicionados a `currentRole == UserRole.admin`.

### AdminUserEditPage

#### Entrada
- Desde `AdminUserDetailsPage` o directamente desde `AdminUsersPage`.
- **Parámetros**: `AdminUser user`, `UserRole currentRole`.

#### Acciones y cadena de llamadas
1. **Guardar**
   - `_save()` → valida `_formKey.currentState?.validate()`.
   - Si cambia contraseña (`_changePassword == true`), envía nuevo password; si no, null.
   - `repository.updateUser(...)` → PUT `/admin/users/{id}`.
   - `Navigator.pop(context, updated)` para devolver usuario actualizado.

#### Estados visuales
- Formulario con campos: username, email, password (opcional en edición), confirm password, dropdown de rol, switch activo.
- **Guardando**: `_isSaving == true` deshabilita botón de guardar.
- **Éxito**: `SnackBar` "Cambios guardados" antes de volver.
- **Error**: `SnackBar` con mensaje de error.

### ServerMetricsPage

#### Entrada
- Desde `AdminPanelPage`.

#### Acciones y cadena de llamadas
1. **Carga inicial**
   - `initState()` → `_loadMetrics()` → `MetricsRepository.fetchAllMetrics()` → GET `{telemetryUrl}/telemetry/system/all`.
2. **Auto-refresh**
   - Timer cada 10 segundos → `_loadMetrics()`.
3. **Refresh manual**
   - IconButton en AppBar.

#### Endpoints
- GET `/telemetry/system/all` (telemetry server, sin auth)
- GET `/telemetry/system` (variante con formato diferente)
- GET `/telemetry/system/database`
- GET `/telemetry/system/ingest`

#### Estados visuales
- **Loading**: `CircularProgressIndicator` si `_metrics == null`.
- **Error**: Icono de error + texto + botón "Reintentar".
- **Con datos**: Secciones de cards: Sistema (CPU/RAM/Uptime), Ingesta (events/s, lecturas, alertas), Base de Datos (sensores, lecturas 24h, alertas).
- **Progress bars**: Uso de CPU y RAM con color rojo si > 80%.
- **Footer**: Timestamp de última actualización.
- **AppBar**: Muestra hora de última actualización junto al título.

## Mapa de endpoints del módulo

| Endpoint | Método | Pantalla(s) que lo usan | Momento exacto del llamado | Dato crítico que retorna | Por qué se muestra en ese punto |
|----------|--------|------------------------|---------------------------|--------------------------|--------------------------------|
| `/admin/users` | GET | `AdminUsersPage` | `initState` + recargas | Lista de usuarios | Gestión de accesos |
| `/admin/users` | POST | `AdminUsersPage` (vía dialog) | Confirmar creación | Usuario creado | Nuevo usuario en sistema |
| `/admin/users/{id}` | PUT | `AdminUserEditPage` | Guardar edición | Usuario actualizado | Modificación de roles/datos |
| `/admin/users/{id}` | DELETE | `AdminUsersPage` / `AdminUserDetailsPage` | Confirmar eliminación | — | Eliminación de acceso |
| `/telemetry/system/all` | GET | `ServerMetricsPage` | `initState` + polling 10s | CPU, RAM, ingesta, DB | Monitoreo de salud del sistema |
| `/telemetry/system` | GET | `MetricsRepository` (fallback) | [PENDIENTE DE VERIFICAR] | Uso básico de CPU/RAM | Variante de métricas |
| `/telemetry/system/database` | GET | `MetricsRepository` | [PENDIENTE DE VERIFICAR] | Métricas de BD | Detalle de base de datos |
| `/telemetry/system/ingest` | GET | `MetricsRepository` | [PENDIENTE DE VERIFICAR] | Métricas de ingesta | Velocidad de procesamiento |

## Diagnóstico UX

- � **Resuelto**: `AdminUsersPage` tiene paginación 20 en 20 con scroll infinito y búsqueda backend.
- 🟢 **Resuelto**: Feedback visual post-acción CRUD con SnackBar (éxito/error) y remoción local sin recarga completa.
- 🟢 **Resuelto**: Confirmación de eliminación estilizada con consecuencia clara (`showDeleteUserDialog`).
- � **Resuelto**: `ServerMetricsPage` muestra timestamp de última actualización en AppBar y tiene auto-refresh + refresh manual.
- 🟡 **Mejora**: `AdminUserEditPage` no valida formato de email ni fortaleza de contraseña; solo verifica campos no vacíos.
- 🟢 **Optimización**: `ServerMetricsPage` podría pausar polling cuando no está visible (`WidgetsBindingObserver` no implementado).
