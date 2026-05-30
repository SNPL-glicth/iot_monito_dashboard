/// Capa de dominio: severidad de predicciones ML.
///
/// Extraída de PredictionHelpers para evitar lógica de negocio
/// embebida en widgets (SRP + Clean Architecture).
library;

enum SeverityLevel { none, low, medium, high, critical }

class PredictionSeverity {
  const PredictionSeverity._();

  static SeverityLevel fromString(String raw) {
    final s = raw.toUpperCase().trim();
    if (s == 'CRITICAL') return SeverityLevel.critical;
    if (s == 'HIGH' || s == 'WARNING') return SeverityLevel.high;
    if (s == 'MEDIUM') return SeverityLevel.medium;
    if (s == 'LOW') return SeverityLevel.low;
    return SeverityLevel.none;
  }

  static String label(SeverityLevel level) => switch (level) {
    SeverityLevel.critical => 'Crítica',
    SeverityLevel.high => 'Alta',
    SeverityLevel.medium => 'Media',
    SeverityLevel.low => 'Baja',
    SeverityLevel.none => 'Normal',
  };
}
