import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';
import '../../core/auth/auth_storage.dart';
import '../../core/auth/token_manager.dart';
import '../../core/auth/user_role.dart';
import '../../core/network/api_client.dart';
import '../../core/notifications/push_notifications_service.dart';
import '../../core/realtime/realtime_service.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/crm/presentation/pages/crm_home_page.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }

    try {
      final stored = await _authStorage.loadSession()
          .timeout(const Duration(milliseconds: 500), onTimeout: () => null);

      if (stored != null && mounted) {
        ApiClient.authToken = stored.token;
        _role = _mapRole(stored.role);

        TokenManager().setRefreshToken(stored.refreshToken);
        TokenManager().startMonitoring(stored.token);
        RealtimeService().connect(authToken: stored.token);

        setState(() {});
      }

      _initFirebaseInBackground();
    } catch (e) {
      debugPrint('Bootstrap error (ignorado): $e');
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
