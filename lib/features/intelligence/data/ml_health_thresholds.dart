/// Umbrales configurables para el semáforo de salud del modelo ML.
///
/// Estos valores determinan el color del indicador visual según
/// accuracy, drift y tiempo desde la última actualización.
class MlHealthThresholds {
  MlHealthThresholds._();

  /// Accuracy: por encima de este valor = verde (saludable).
  static const double accuracyGreen = 0.90;

  /// Accuracy: por debajo de este valor = rojo (crítico).
  static const double accuracyRed = 0.70;

  /// Drift: por debajo de este valor = verde (estable).
  static const double driftGreen = 0.05;

  /// Drift: por encima de este valor = rojo (degradado).
  static const double driftRed = 0.15;

  /// Horas máximas desde última actualización para verde.
  static const int lastUpdateHoursGreen = 24;

  /// Horas máximas desde última actualización para amarillo.
  static const int lastUpdateHoursYellow = 72;

  /// Color según accuracy (0.0-1.0).
  static String accuracyStatus(double accuracy) {
    if (accuracy >= accuracyGreen) return 'green';
    if (accuracy <= accuracyRed) return 'red';
    return 'yellow';
  }

  /// Color según drift (0.0-1.0).
  static String driftStatus(double drift) {
    if (drift <= driftGreen) return 'green';
    if (drift >= driftRed) return 'red';
    return 'yellow';
  }

  /// Color según horas desde última actualización.
  static String freshnessStatus(int hoursSinceUpdate) {
    if (hoursSinceUpdate <= lastUpdateHoursGreen) return 'green';
    if (hoursSinceUpdate <= lastUpdateHoursYellow) return 'yellow';
    return 'red';
  }
}
