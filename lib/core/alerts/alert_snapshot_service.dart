/// Re-exporta modelos y servicio de snapshots de alertas por compatibilidad.
///
/// Este archivo mantiene compatibilidad con código existente que importa
/// desde alert_snapshot_service.dart. Los modelos y servicio ahora están en archivos separados.
library;

// Modelos
export 'models/alert_snapshot_models.dart';

// Servicio de snapshots
export 'alert_snapshot_service_impl.dart';
