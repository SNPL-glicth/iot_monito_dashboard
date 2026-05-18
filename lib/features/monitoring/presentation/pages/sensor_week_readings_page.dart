import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/time/network_clock.dart';
import '../../data/models/monitoring_view_models.dart';
import '../../data/monitoring_repository.dart';
import '../styles/dashboard_styles.dart';

class SensorWeekReadingsPage extends StatelessWidget {
  const SensorWeekReadingsPage({
    super.key,
    required this.role,
    required this.sensorId,
    this.sensorNameHint,
    this.unitHint,
    this.limit = 5000,
  });

  final UserRole role;
  final String sensorId;
  final String? sensorNameHint;
  final String? unitHint;
  final int limit;

  static const List<String> _weekdaysEs = <String>[
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo',
  ];

  static DateTime? _parseBogota(String raw) {
    final iso = DateTime.tryParse(raw);
    if (iso == null) return null;
    return iso.isUtc ? NetworkClock.utcToBogota(iso) : iso;
  }

  static String _fmtTime(String raw) {
    final ts = _parseBogota(raw);
    if (ts == null) return raw;
    return DateFormat('HH:mm').format(ts);
  }

  static List<SensorReadingViewModel> _pickDayReadings(List<SensorReadingViewModel> readings) {
    // Para evitar cuelgues: mostramos un subconjunto pequeño.
    // Requisito: mostrar solo lecturas de la tarde (12 PM - 10 PM) y máximo 10.
    final afternoon = readings.where((r) {
      final ts = _parseBogota(r.timestamp);
      if (ts == null) return false;
      // 12:00 (12 PM) hasta 22:59 (10:59 PM)
      return ts.hour >= 12 && ts.hour <= 22;
    }).toList();

    // readings ya viene ordenado desc por timestamp (más reciente primero)
    if (afternoon.length <= 10) return afternoon;
    return afternoon.take(10).toList();
  }

  Future<_WeekData> _load(MonitoringRepository repo) async {
    final now = await NetworkClock.nowBogota();

    // Semana actual (Lunes..Domingo) en Colombia.
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));
    final sundayEndExclusive = monday.add(const Duration(days: 7));

    final all = await repo.fetchSensorReadings(sensorId, limit: limit);

    // Filtramos por timestamps convertidos a Bogotá.
    final weekItems = all.where((r) {
      final ts = _parseBogota(r.timestamp);
      if (ts == null) return false;
      final d = DateTime(ts.year, ts.month, ts.day);
      return !d.isBefore(monday) && d.isBefore(sundayEndExclusive);
    }).toList();

    // Agrupar por día.
    final byDay = <DateTime, List<SensorReadingViewModel>>{};
    for (var i = 0; i < 7; i++) {
      byDay[monday.add(Duration(days: i))] = <SensorReadingViewModel>[];
    }

    for (final r in weekItems) {
      final ts = _parseBogota(r.timestamp);
      if (ts == null) continue;
      final dayKey = DateTime(ts.year, ts.month, ts.day);
      final list = byDay[dayKey];
      if (list != null) list.add(r);
    }

    // Ordenar cada día por hora (desc: más reciente arriba).
    for (final entry in byDay.entries) {
      entry.value.sort((a, b) {
        final ta = _parseBogota(a.timestamp);
        final tb = _parseBogota(b.timestamp);
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });
    }

    return _WeekData(
      nowBogota: now,
      monday: monday,
      endExclusive: sundayEndExclusive,
      byDay: byDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = (sensorNameHint == null || sensorNameHint!.trim().isEmpty)
        ? 'Semana · Sensor #$sensorId'
        : sensorNameHint!;

    final unit = (unitHint ?? '').trim();

    final repo = MonitoringRepository();
    final future = _load(repo);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<_WeekData>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error cargando lecturas: ${snapshot.error}',
                  style: DashboardTextStyles.error,
                  textAlign: TextAlign.center,
                ),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(
                child: Text('No hay datos.', style: DashboardTextStyles.sensorMeta),
              );
            }

            final today = DateTime(data.nowBogota.year, data.nowBogota.month, data.nowBogota.day);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Semana: ${DateFormat('dd/MM').format(data.monday)} - "
                  "${DateFormat('dd/MM').format(data.endExclusive.subtract(const Duration(days: 1)))}",
                  style: DashboardTextStyles.smallLabel,
                ),
                const SizedBox(height: 12),
                Column(
                  children: List<Widget>.generate(7, (index) {
                    final day = data.monday.add(Duration(days: index));
                    final label = _weekdaysEs[index];
                    final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
                    final readings = data.byDay[day] ?? const <SensorReadingViewModel>[];
                    final picked = _pickDayReadings(readings);

                    final countLabel = readings.isEmpty
                        ? 'Sin lecturas'
                        : 'Mostrando ${picked.length} de ${readings.length}';

                    return Card(
                      child: ExpansionTile(
                        initiallyExpanded: isToday,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(label, style: DashboardTextStyles.sensorTitle),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: Text('HOY', style: DashboardTextStyles.chipActive),
                                backgroundColor: Colors.green.withValues(alpha: 0.18),
                                side: BorderSide(color: DashboardTextStyles.chipActive.color!),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${DateFormat('dd/MM').format(day)} · $countLabel',
                          style: DashboardTextStyles.sensorMeta,
                        ),
                        children: [
                          if (readings.isEmpty)
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'No hay lecturas para este día.',
                                style: DashboardTextStyles.sensorMeta,
                              ),
                            )
                          else if (picked.isEmpty)
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'No hay lecturas en el rango de tarde (12:00 - 22:59).',
                                style: DashboardTextStyles.sensorMeta,
                              ),
                            )
                          else
                            ...picked.map((r) {
                              final value = unit.isEmpty ? r.value : '${r.value} $unit';
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.show_chart, color: Colors.white70, size: 20),
                                title: Text(value, style: DashboardTextStyles.sensorTitle),
                                subtitle: Text(_fmtTime(r.timestamp), style: DashboardTextStyles.sensorMeta),
                              );
                            }),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      );
  }
}

class _WeekData {
  _WeekData({
    required this.nowBogota,
    required this.monday,
    required this.endExclusive,
    required this.byDay,
  });

  final DateTime nowBogota;
  final DateTime monday;
  final DateTime endExclusive;
  final Map<DateTime, List<SensorReadingViewModel>> byDay;
}
