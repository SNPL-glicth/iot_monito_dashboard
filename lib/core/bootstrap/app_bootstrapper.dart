import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';
import '../../core/auth/auth_storage.dart';
import '../../core/auth/token_manager.dart';
import '../../core/auth/user_role.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_error_interceptor.dart';
import '../../core/notifications/push_notifications_service.dart';
import '../../core/presentation/widgets/app_loading_widget.dart';
import '../../core/realtime/realtime_service.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/crm/presentation/pages/crm_home_page.dart';
import '../../features/monitoring/presentation/styles/dashboard_styles.dart';

bool _firebaseReady = false;

bool get _isFirebaseSupported {
  if (kIsWeb) return true;
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    return false;
  }
  return true;
}

Future<void> _initFirebaseDeferred() async {
  if (_firebaseReady) return;
  if (!_isFirebaseSupported) {
    debugPrint('Firebase no soportado en esta plataforma, omitiendo inicialización');
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseReady = true;
    debugPrint('Firebase inicializado correctamente (diferido)');
  } catch (e) {
    debugPrint('Firebase.initializeApp() failed: $e');
  }
}

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  final AuthStorage _authStorage = AuthStorage();
  bool _loading = true;
  UserRole? _role;
  String? _sessionErrorMessage;
  StreamSubscription<UnauthorizedEvent>? _unauthorizedSub;

  @override
  void initState() {
    super.initState();
    _unauthorizedSub = ApiErrorInterceptor().onUnauthorized.listen((event) {
      if (!mounted) return;
      _clearSession();
      _sessionErrorMessage = event.message;
      _finishLoading();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(event.message)),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      // 1. Cargar sesión con timeout de 3 segundos (no 500ms)
      final stored = await _authStorage
          .loadSession()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);

      if (stored != null && mounted) {
        ApiClient.authToken = stored.token;
        final tokenManager = TokenManager();
        tokenManager.setRefreshToken(stored.refreshToken);

        // 2. Validar si el token expiró o está próximo a expirar
        final isExpired = tokenManager.isTokenExpired(stored.token);
        final isExpiringSoon = tokenManager.isTokenExpiringSoon(stored.token);

        if (isExpired || isExpiringSoon) {
          // Intentar refresh automático antes de redirigir
          final refreshed = await tokenManager
              .refreshTokenNow()
              .timeout(const Duration(seconds: 5), onTimeout: () => false);

          if (!refreshed) {
            // Refresh falló: limpiar todo y preparar mensaje para login
            await _clearSession();
            _sessionErrorMessage =
                'Tu sesión expiró. Por favor inicia sesión de nuevo.';
            _finishLoading();
            return;
          }
        }

        // Token válido o refresh exitoso
        _role = _mapRole(stored.role);
        tokenManager.startMonitoring(ApiClient.authToken ?? stored.token);
        RealtimeService().connect(authToken: ApiClient.authToken ?? stored.token);
      }

      _finishLoading();
      _initFirebaseInBackground();
    } catch (e) {
      debugPrint('Bootstrap error: $e');
      // Nunca dejar al usuario en una pantalla en blanco
      await _clearSession();
      _finishLoading();
    }
  }

  Future<void> _clearSession() async {
    try {
      await _authStorage.clearSession();
    } catch (_) {
      // Ignorar errores de limpieza
    }
    ApiClient.authToken = null;
    TokenManager().stopMonitoring();
  }

  void _finishLoading() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _initFirebaseInBackground() {
    Future.microtask(() async {
      try {
        await _initFirebaseDeferred();

        if (_firebaseReady && _isFirebaseSupported && mounted) {
          PushNotificationsService.instance.init(context: context);
        }
      } catch (e) {
        debugPrint('Firebase background init error: $e');
      }
    });
  }

  UserRole _mapRole(String raw) {
    switch (raw.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'viewer':
      default:
        return UserRole.viewer;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildSplashScreen();
    }

    if (_role != null) {
      return CrmHomePage(role: _role!);
    }

    return LoginPage(initialErrorMessage: _sessionErrorMessage);
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo con gradiente
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: DashboardColors.gradientPrimary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: DashboardColors.primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sensors_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'IoT System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inicializando...',
              style: TextStyle(
                color: DashboardColors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 32,
              height: 32,
              child: AppLoadingWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
