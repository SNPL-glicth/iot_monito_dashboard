import 'dart:ui';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/bootstrap/app_bootstrapper.dart';
import 'core/lifecycle/app_lifecycle_service.dart';
import 'core/navigation/app_router.dart';
import 'core/network/api_error_interceptor.dart';
import 'core/theme/app_theme.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler for Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In production, log to console (or replace with crash reporting service)
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
    } else {
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
      debugPrint(details.stack.toString());
    }
  };

  // Catch async errors not handled by Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[PlatformDispatcher] Unhandled error: $error');
    if (!kReleaseMode) {
      debugPrint(stack.toString());
    }
    return true; // true = handled, do not rethrow
  };

  // Custom error widget for build/render errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return _SensorErrorWidget(details: details);
  };

  AppLifecycleService().attach();
  ApiErrorInterceptor().attachScaffoldMessengerKey(rootScaffoldMessengerKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Monitoring Dashboard',
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: !kReleaseMode && const bool.fromEnvironment('SHOW_PERFORMANCE'),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CO'),
        Locale('es'),
        Locale('en'),
      ],
      locale: const Locale('es', 'CO'),
      theme: AppTheme.dark(),
      onGenerateRoute: AppRouter.onGenerate,
      home: const AppBootstrapper(),
    );
  }
}

/// Custom error widget shown when a widget fails to build.
class _SensorErrorWidget extends StatelessWidget {
  const _SensorErrorWidget({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final isDebug = !kReleaseMode;

    return Material(
      child: Container(
        color: const Color(0xFF1A1A2E),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sensors_off,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              const Text(
                'Este sensor no esta disponible temporalmente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (isDebug)
                Text(
                  '${details.exceptionAsString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate back or trigger a retry via the navigator
                  final navigator = Navigator.of(context, rootNavigator: true);
                  if (navigator.canPop()) {
                    navigator.pop();
                  } else {
                    navigator.pushReplacementNamed('/');
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
