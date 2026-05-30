import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/user_role.dart';
import '../../../../core/time/network_clock.dart';
import '../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


class SensorReadingsPage extends StatelessWidget {
  const SensorReadingsPage({
    super.key,
    required this.role,
    required this.sensorId,
    this.sensorNameHint,
    this.unitHint,
    this.limit = 200,
    this.filterLabel,
    this.filterRange,
  });

  final UserRole role;
  final String sensorId;
  final String? sensorNameHint;
  final String? unitHint;
  final int limit;

  /// Etiqueta visible (ej: "Hoy", "Últimos 7 días", "Marzo 2025").
  final String? filterLabel;

  /// Rango de fechas para filtrar lecturas (se interpreta en hora Colombia/Bogotá).
  ///
  /// Semántica usada en el filtrado: start inclusive, end exclusive.
  final DateTimeRange? filterRange;

  static DateTime? _parseBogota(String raw) {
    final iso = DateTime.tryParse(raw);
    if (iso == null) return null;

    // Si el backend manda UTC (lo más común), lo convertimos a UTC-5 para Colombia.
    // Si viene sin zona (isUtc=false), asumimos que ya está en hora local del sistema.
    final bogota = iso.isUtc ? NetworkClock.utcToBogota(iso) : iso;
    return bogota;
  }

  static String _fmt(String raw) {
    final dt = _parseBogota(raw);
    if (dt != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final title = (sensorNameHint == null || sensorNameHint!.trim().isEmpty)
        ? 'Lecturas del sensor #$sensorId'
        : sensorNameHint!;

    final unit = (unitHint ?? '').trim();

    final repo = MonitoringRepository();
    final range = filterRange;
    final future = repo.fetchSensorReadings(
      sensorId,
      limit: limit,
      from: range?.start,
      to: range?.end,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, overflow: TextOverflow.ellipsis),
            if (filterLabel != null && filterLabel!.trim().isNotEmpty)
              Text(filterLabel!, style: DesignTextStyles.timestamp),
          ],
        ),
      ),
      body: FutureBuilder<List<SensorReadingViewModel>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error cargando lecturas: ${snapshot.error}',
                  style: DesignTextStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
              );
            }

            final items = snapshot.data ?? const <SensorReadingViewModel>[];

            if (items.isEmpty) {
              return Center(
                child: Text('No hay lecturas registradas.', style: DesignTextStyles.bodyText),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(DesignSpacing.lg),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final r = items[index];
                final ts = _fmt(r.timestamp);
                final value = unit.isEmpty ? r.value : '${r.value} $unit';

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.show_chart, color: DesignColors.textPrimary),
                    title: Text(value, style: DesignTextStyles.bodyText),
                    subtitle: Text(ts, style: DesignTextStyles.bodyText),
                  ),
                );
              },
            );
          },
        ),
      );
  }
}
