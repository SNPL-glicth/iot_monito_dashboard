import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// URL base del backend NestJS (puerto 3000).
  /// 
  /// Detecta automáticamente la plataforma:
  /// - Web/Windows/Linux/macOS: localhost:3000
  /// - Android emulador: 10.0.2.2:3000
  /// - Android físico: usa la IP de tu máquina
  static String get baseUrl {
    // Web siempre usa localhost
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    
    // Desktop (Windows, Linux, macOS) usa localhost
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:3000';
    }
    
    // Android emulador usa IP especial del host
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    
    // iOS simulador usa localhost
    if (Platform.isIOS) {
      return 'http://localhost:3000';
    }
    
    // Fallback
    return 'http://localhost:3000';
  }

  /// URL base del servidor de telemetría (puerto 8099).
  /// Usado para métricas del sistema, trading data, etc.
  static String get telemetryUrl {
    if (kIsWeb) {
      return 'http://localhost:8099';
    }
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:8099';
    }
    
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8099';
    }
    
    if (Platform.isIOS) {
      return 'http://localhost:8099';
    }
    
    return 'http://localhost:8099';
  }
}
