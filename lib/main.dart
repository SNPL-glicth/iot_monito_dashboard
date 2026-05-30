import 'dart:ui';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/bootstrap/app_bootstrapper.dart';
import 'core/lifecycle/app_lifecycle_service.dart';
import 'core/navigation/app_router.dart';
import 'core/network/api_error_interceptor.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/design_colors.dart';
import 'core/theme/design_spacing.dart';
import 'core/theme/design_text_styles.dart';

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
        color: DesignColors.background,
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sensors_off,
                  size: 64, color: DesignColors.textSecondary),
              SizedBox(height: DesignSpacing.md),
              Text(
                'Este sensor no esta disponible temporalmente',
                textAlign: TextAlign.center,
                style: DesignTextStyles.cardTitle.copyWith(fontSize: 18),
              ),
              SizedBox(height: DesignSpacing.sm),
              if (isDebug)
                Text(
                  details.exceptionAsString(),
                  textAlign: TextAlign.center,
                  style: DesignTextStyles.timestamp,
                ),
              SizedBox(height: DesignSpacing.xl),
              ElevatedButton.icon(
                onPressed: () {
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
