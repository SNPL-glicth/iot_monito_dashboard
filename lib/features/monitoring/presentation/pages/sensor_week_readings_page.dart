import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/time/network_clock.dart';
import '../../data/models/monitoring_view_models.dart';
import '../../data/monitoring_repository.dart';
import '../styles/dashboard_styles.dart';
import '../widgets/week_readings/week_data.dart';
import '../widgets/week_readings/week_day_card.dart';
import '../widgets/week_readings/week_readings_skeleton.dart';

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
    'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo',
  ];

  Future<WeekData> _load(MonitoringRepository repo) async {
    final now = await NetworkClock.nowBogota();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));
    final sundayEndExclusive = monday.add(const Duration(days: 7));

    final weekItems = await repo.fetchSensorReadings(
      sensorId, limit: limit, from: monday, to: sundayEndExclusive,
    );

    final byDay = <DateTime, List<SensorReadingViewModel>>{};
    for (var i = 0; i < 7; i++) {
      byDay[monday.add(Duration(days: i))] = <SensorReadingViewModel>[];
    }

    for (final r in weekItems) {
      final ts = parseBogota(r.timestamp);
      if (ts == null) continue;
      final dayKey = DateTime(ts.year, ts.month, ts.day);
      byDay[dayKey]?.add(r);
    }

    for (final entry in byDay.entries) {
      entry.value.sort((a, b) {
        final ta = parseBogota(a.timestamp);
        final tb = parseBogota(b.timestamp);
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });
    }

    return WeekData(nowBogota: now, monday: monday, endExclusive: sundayEndExclusive, byDay: byDay);
  }

  @override
  Widget build(BuildContext context) {
    final title = (sensorNameHint == null || sensorNameHint!.trim().isEmpty)
        ? 'Semana · Sensor #$sensorId' : sensorNameHint!;
    final unit = (unitHint ?? '').trim();
    final repo = MonitoringRepository();

    return Scaffold(
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      body: FutureBuilder<WeekData>(
        future: _load(repo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WeekReadingsSkeleton();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error cargando lecturas: ${snapshot.error}',
                  style: DashboardTextStyles.error, textAlign: TextAlign.center),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('No hay datos.', style: DashboardTextStyles.sensorMeta));
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
                  return WeekDayCard(
                    label: _weekdaysEs[index],
                    day: day,
                    isToday: day.year == today.year && day.month == today.month && day.day == today.day,
                    readings: data.byDay[day] ?? const <SensorReadingViewModel>[],
                    unit: unit,
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
