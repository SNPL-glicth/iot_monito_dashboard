import 'package:intl/intl.dart';

import '../../../../../core/time/network_clock.dart';
import '../../../data/models/monitoring_view_models.dart';

class WeekData {
  WeekData({
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

DateTime? parseBogota(String raw) {
  final iso = DateTime.tryParse(raw);
  if (iso == null) return null;
  return iso.isUtc ? NetworkClock.utcToBogota(iso) : iso;
}

String fmtTime(String raw) {
  final ts = parseBogota(raw);
  if (ts == null) return raw;
  return DateFormat('HH:mm').format(ts);
}

List<SensorReadingViewModel> pickDayReadings(List<SensorReadingViewModel> readings) {
  final afternoon = readings.where((r) {
    final ts = parseBogota(r.timestamp);
    if (ts == null) return false;
    return ts.hour >= 12 && ts.hour <= 22;
  }).toList();

  if (afternoon.length <= 10) return afternoon;
  return afternoon.take(10).toList();
}
