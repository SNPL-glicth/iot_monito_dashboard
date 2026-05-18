import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../../data/raw_readings_repository.dart';

/// Vista de gráfica de lecturas crudas para un sensor específico.
class RawReadingsChartView extends StatefulWidget {
  const RawReadingsChartView({
    super.key,
    required this.sensorId,
    required this.sensorName,
    this.unit,
  });

  final String sensorId;
  final String sensorName;
  final String? unit;

  @override
  State<RawReadingsChartView> createState() => _RawReadingsChartViewState();
}

class _RawReadingsChartViewState extends State<RawReadingsChartView> {
  final RawReadingsRepository _repo = RawReadingsRepository();

  int _hoursBack = 1;
  Future<RawReadingsResponse>? _dataFuture;
  bool _isLoading = false;

  List<FlSpot>? _cachedSpots;
  List<RawReading>? _cachedReadings;
  double? _cachedMinY;
  double? _cachedMaxY;
  int? _lastDataHash;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await _repo.fetchRawReadings(
        sensorId: widget.sensorId,
        hours: _hoursBack,
      );

      if (!mounted) return;

      final newHash = response.readings.length ^
          (response.readings.isNotEmpty
              ? response.readings.last.timestamp.millisecondsSinceEpoch
              : 0);
      if (newHash != _lastDataHash) {
        _cachedSpots = null;
        _cachedReadings = null;
        _lastDataHash = newHash;
      }

      setState(() {
        _dataFuture = Future.value(response);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dataFuture = Future.error(e);
        _isLoading = false;
      });
    }
  }

  void _processAndCacheData(List<RawReading> rawReadings) {
    final readings = List<RawReading>.from(rawReadings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final limited = readings.length > 500
        ? readings.sublist(readings.length - 500)
        : readings;

    final spots = limited.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    if (limited.isNotEmpty) {
      final values = limited.map((r) => r.value).toList();
      _cachedMinY = values.reduce((a, b) => a < b ? a : b);
      _cachedMaxY = values.reduce((a, b) => a > b ? a : b);
    }

    _cachedReadings = limited;
    _cachedSpots = spots;
  }

  void _onHoursChanged(int hours) {
    if (hours == _hoursBack) return;
    setState(() => _hoursBack = hours);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.white54, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Período:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(width: 12),
              ...[1, 6, 12, 24].map((h) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${h}h'),
                      selected: _hoursBack == h,
                      onSelected: (_) => _onHoursChanged(h),
                      selectedColor: Colors.tealAccent.withValues(alpha: 0.3),
                      labelStyle: TextStyle(
                        color: _hoursBack == h
                            ? Colors.tealAccent
                            : Colors.white70,
                        fontSize: 12,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  )),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildChart(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_dataFuture == null) {
      return const Center(
        child: Text('Seleccione un sensor',
            style: DashboardTextStyles.sensorMeta),
      );
    }

    return FutureBuilder<RawReadingsResponse>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Error: ${snapshot.error}',
                  style: DashboardTextStyles.error,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data;
        if (data == null || data.readings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline,
                    color: Colors.white.withValues(alpha: 0.5), size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Sin lecturas en este período',
                  style: DashboardTextStyles.sensorMeta,
                ),
                Text(
                  'El sensor puede no estar reportando datos',
                  style:
                      TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                ),
              ],
            ),
          );
        }

        if (_cachedSpots == null || _cachedReadings == null) {
          _processAndCacheData(data.readings);
        }

        final readings = _cachedReadings!;
        final spots = _cachedSpots!;
        final minY = _cachedMinY ?? 0;
        final maxY = _cachedMaxY ?? 1;
        final padding = (maxY - minY) * 0.1;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${data.count} lecturas',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                ),
                if (widget.unit != null && widget.unit!.isNotEmpty)
                  Text(
                    'Unidad: ${widget.unit}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RepaintBoundary(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxY - minY) / 4,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: readings.length > 4
                              ? (readings.length / 4)
                                  .floorToDouble()
                                  .clamp(1, double.infinity)
                              : 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.round();
                            if (idx < 0 || idx >= readings.length) {
                              return const SizedBox.shrink();
                            }
                            final dt = readings[idx].timestamp.toLocal();
                            return Text(
                              DateFormat('HH:mm').format(dt),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 9,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: minY - padding,
                    maxY: maxY + padding,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.2,
                        color: Colors.tealAccent,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: readings.length < 50,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 2,
                              color: Colors.tealAccent,
                              strokeWidth: 0,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.tealAccent.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.round();
                            if (idx < 0 || idx >= readings.length) return null;
                            final reading = readings[idx];
                            final dt = reading.timestamp.toLocal();
                            return LineTooltipItem(
                              '${reading.value.toStringAsFixed(2)}${widget.unit != null ? ' ${widget.unit}' : ''}\n${DateFormat('HH:mm:ss').format(dt)}',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
