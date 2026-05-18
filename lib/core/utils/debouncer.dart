import 'dart:async';

import 'package:flutter/widgets.dart';

/// Debouncer para evitar operaciones excesivas en inputs de texto.
/// 
/// FIX CRÍTICO: Previene freezes de UI causados por:
/// - HTTP requests en cada keystroke
/// - Cálculos pesados en onChanged
/// - setState() global por cada tecla
/// 
/// Uso:
/// ```dart
/// final _debouncer = Debouncer(milliseconds: 300);
/// 
/// TextField(
///   onChanged: (value) {
///     _debouncer.run(() {
///       // Operación pesada aquí (HTTP, cálculos, etc.)
///     });
///   },
/// )
/// ```
class Debouncer {
  Debouncer({this.milliseconds = 300});

  final int milliseconds;
  Timer? _timer;

  /// Ejecuta la acción después del delay, cancelando cualquier acción pendiente.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancela cualquier acción pendiente.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Libera recursos. Llamar en dispose() del widget.
  void dispose() {
    cancel();
  }

  /// Indica si hay una acción pendiente.
  bool get isPending => _timer?.isActive ?? false;
}

/// Throttler para limitar la frecuencia de operaciones.
/// 
/// A diferencia del Debouncer, ejecuta la primera acción inmediatamente
/// y luego ignora llamadas adicionales hasta que pase el intervalo.
/// 
/// Ideal para:
/// - Gestos de scroll/pan
/// - Actualizaciones de gráficas
/// - Polling manual
class Throttler {
  Throttler({this.milliseconds = 100});

  final int milliseconds;
  DateTime? _lastRun;

  /// Ejecuta la acción si ha pasado suficiente tiempo desde la última ejecución.
  void run(void Function() action) {
    final now = DateTime.now();
    if (_lastRun == null || 
        now.difference(_lastRun!).inMilliseconds >= milliseconds) {
      _lastRun = now;
      action();
    }
  }

  /// Resetea el throttler, permitiendo la siguiente acción inmediatamente.
  void reset() {
    _lastRun = null;
  }
}

/// Mixin para widgets que necesitan debouncing en TextFields.
/// 
/// Uso:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with TextFieldDebounceMixin {
///   @override
///   void dispose() {
///     disposeDebouncer();
///     super.dispose();
///   }
///   
///   void _onSearchChanged(String value) {
///     debounce(() {
///       // Búsqueda HTTP aquí
///     });
///   }
/// }
/// ```
mixin TextFieldDebounceMixin<T extends StatefulWidget> on State<T> {
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  /// Ejecuta una acción con debounce.
  void debounce(void Function() action) {
    _debouncer.run(action);
  }

  /// Ejecuta una acción con debounce personalizado.
  void debounceMs(int milliseconds, void Function() action) {
    _debouncer._timer?.cancel();
    _debouncer._timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancela cualquier acción pendiente.
  void cancelDebounce() {
    _debouncer.cancel();
  }

  /// Libera recursos del debouncer. Llamar en dispose().
  void disposeDebouncer() {
    _debouncer.dispose();
  }
}
