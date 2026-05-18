//Sonde se importan los paquetes  principales 
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/auth/auth_storage.dart';
import 'core/auth/token_manager.dart';
import 'core/auth/user_role.dart';
import 'core/network/api_client.dart';
import 'core/notifications/push_notifications_service.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/crm/presentation/pages/crm_home_page.dart';
import 'features/devices/presentation/pages/add_device_screen.dart';
import 'features/devices/presentation/pages/device_detail_page.dart';
import 'features/devices/presentation/pages/sensor_details_route_page.dart';

// Flag global simple para saber si Firebase se inicializó correctamente.
bool _firebaseReady = false;

/// Verifica si Firebase es soportado en la plataforma actual
bool get _isFirebaseSupported {
  if (kIsWeb) return true;
  // Firebase no está bien soportado en Windows/Linux desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    return false;
  }
  return true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // FIX FASE 1.3: NO inicializar Firebase aquí - bloquea el arranque
  // Firebase se inicializa de forma diferida en _RootRouterState
  // Esto permite que la UI se renderice inmediatamente
  
  runApp(const MyApp());
}

/// Inicializa Firebase de forma diferida (no bloqueante)
/// Llamar después del primer frame para no bloquear el arranque
Future<void> _initFirebaseDeferred() async {
  if (_firebaseReady) return; // Ya inicializado
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

class MyApp extends StatelessWidget {// por done inicia  la clase app
  const MyApp({super.key});

  @override// el widget por donde empiza construirse el contexto
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Monitoring Dashboard',//Nada mas el titulo arriba de la aplicacion
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: !kReleaseMode && const bool.fromEnvironment('SHOW_PERFORMANCE'), // Enable with --dart-define=SHOW_PERFORMANCE=true
      
      // FIX: Localización para evitar warnings de AssetManager2
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CO'), // Español Colombia (principal)
        Locale('es'),       // Español genérico
        Locale('en'),       // Inglés fallback
      ],
      locale: const Locale('es', 'CO'),
      
      // Tema global oscuro para todo el dashboard
      theme: ThemeData(
        useMaterial3: true,
        // Esquema de color realmente oscuro para que drawers, diálogos y fondos
        // sean coherentes con el resto del diseño.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        // color de fondo oscuro para el dashboard
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        // estilo global de las cards en toda la app
        cardTheme: const CardThemeData(
          color: Color(0xFF111827),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 6),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        // Estilo por defecto para los TextField / TextFormField (texto blanco visible sobre fondo oscuro)
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF020617),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        // Drawer y ListTile por defecto con fondo y texto oscuros / claros
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF020617),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white70,
          textColor: Colors.white,
        ),
        // Diálogos coherentes con el tema oscuro si no habla 
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF020617),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';

        // Agregar dispositivo (pantalla simple: solo nombre)
        if (name == '/devices/create' || name == '/devices/add') {
          return MaterialPageRoute(
            builder: (_) => const AddDeviceScreen(),
            settings: settings,
          );
        }

        // REST-style: /device/<deviceId>
        if (name.startsWith('/device/')) {
          final deviceId = name.substring('/device/'.length);
          if (deviceId.trim().isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => DeviceDetailPage(
                role: UserRole.admin,
                deviceId: deviceId,
                deviceName: 'Dispositivo',
              ),
              settings: settings,
            );
          }
        }

        // REST-style: /sensor/<sensorId>
        if (name.startsWith('/sensor/')) {
          final sensorId = name.substring('/sensor/'.length);
          if (sensorId.trim().isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => SensorDetailsRoutePage(
                args: SensorDetailsArgs(sensorId: sensorId),
              ),
              settings: settings,
            );
          }
        }

        // Backward compatible: /sensor-details + arguments
        if (name == '/sensor-details') {
          final args = settings.arguments;
          if (args is SensorDetailsArgs) {
            return MaterialPageRoute(
              builder: (_) => SensorDetailsRoutePage(args: args),
              settings: settings,
            );
          }
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Ruta /sensor-details requiere SensorDetailsArgs'),
              ),
            ),
            settings: settings,
          );
        }
        return null;
      },
      home: const _RootRouter(),
    );
  }
}

/// Decide si se muestra el Login o se entra directo al CRM según haya
/// una sesión persistida ("mantener sesión iniciada"). pero a medias 
class _RootRouter extends StatefulWidget {
  const _RootRouter();

  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  final AuthStorage _authStorage = AuthStorage();
  bool _loading = true;
  UserRole? _role;

  @override
  void initState() {
    super.initState();
    // FIX FASE 1.3: Diferir bootstrap al primer frame para no bloquear render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    // FIX PERFORMANCE: Mostrar UI PRIMERO, luego cargar sesión
    // Esto permite que el usuario vea algo inmediatamente
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
    
    try {
      // FIX FREEZE: Cargar sesión en background (ya no bloquea UI)
      // SharedPreferences en debug es instantáneo
      final stored = await _authStorage.loadSession()
          .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
      
      if (stored != null && mounted) {
        // Restaura token en ApiClient para que todas las llamadas vayan autenticadas.
        ApiClient.authToken = stored.token;
        _role = _mapRole(stored.role);
        
        // FIX AUTH: Restaurar refresh token para poder refrescar sesión
        TokenManager().setRefreshToken(stored.refreshToken);
        
        // FIX AUTH: Iniciar monitoreo de token para refresh automático
        TokenManager().startMonitoring(stored.token);
        
        // Actualizar UI con el rol encontrado
        setState(() {});
      }
      
      // FIX FASE 1.3: Inicializar Firebase en background completo
      // No esperamos - fire and forget
      _initFirebaseInBackground();
    } catch (e) {
      // Si algo falla, se ignora y se vuelve al login normal.
      debugPrint('Bootstrap error (ignorado): $e');
    }
  }
  
  /// Inicializa Firebase completamente en background sin bloquear nada
  void _initFirebaseInBackground() {
    Future.microtask(() async {
      try {
        await _initFirebaseDeferred();
        
        // Inicializar notificaciones push solo si Firebase está listo
        if (_firebaseReady && _isFirebaseSupported && mounted) {
          // Fire-and-forget, no esperamos resultado
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_role != null) {
      return CrmHomePage(role: _role!);
    }

    return const LoginPage();
  }
}
