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
