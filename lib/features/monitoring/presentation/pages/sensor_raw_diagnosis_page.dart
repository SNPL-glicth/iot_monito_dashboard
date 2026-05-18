import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/user_role.dart';
import '../../data/models/monitoring_view_models.dart';
import '../../data/monitoring_repository.dart';
import '../styles/dashboard_styles.dart';
import '../widgets/raw_diagnosis/raw_sensor_chart.dart';
import '../widgets/raw_diagnosis/raw_readings_list.dart';

/// FIX PROBLEMA 5 & 8: Página de diagnóstico con datos CRUDOS.
/// 
/// Características:
/// - Muestra TODAS las lecturas sin agregación ni compresión
/// - Se actualiza automáticamente cada 10 segundos
/// - Gráfica crece en el tiempo (scroll horizontal)
/// - NO muestra alertas ni advertencias, SOLO lecturas reales
/// - Selector de sensor
class SensorRawDiagnosisPage extends StatefulWidget {
  const SensorRawDiagnosisPage({
    super.key,
    required this.role,
    required this.sensorId,
    required this.sensorName,
    required this.unit,
  });

  final UserRole role;
  final String sensorId;
  final String sensorName;
  final String unit;

  @override
  State<SensorRawDiagnosisPage> createState() => _SensorRawDiagnosisPageState();
}

class _SensorRawDiagnosisPageState extends State<SensorRawDiagnosisPage> {
  late final MonitoringRepository _repo;
  
  RawSensorReadingsViewModel? _data;
  bool _loading = true;
  String? _error;
  
  Timer? _poller;
  DateTime? _lastFetchedAt;
  
  // Límite de lecturas a mostrar
  int _limit = 200;
  
  // Scroll controller para la gráfica
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _repo = MonitoringRepository();
    _loadData();
    
    // Polling cada 10 segundos para datos en tiempo real
    _poller = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _loadData(silent: true);
    });
  }

  @override
  void dispose() {
    _poller?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final data = await _repo.fetchRawSensorReadings(
        widget.sensorId,
        limit: _limit,
      );
      
      if (!mounted) return;
      
      setState(() {
        _data = data;
        _loading = false;
        _error = null;
        _lastFetchedAt = DateTime.now();
      });
      
      // Scroll al final para mostrar datos más recientes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      appBar: AppBar(
        backgroundColor: DashboardColors.cardBackground,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnóstico: ${widget.sensorName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Datos crudos en tiempo real',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Selector de límite
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Límite de lecturas',
            onSelected: (value) {
              setState(() {
                _limit = value;
              });
              _loadData();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 100, child: Text('Últimas 100')),
              PopupMenuItem(value: 200, child: Text('Últimas 200')),
              PopupMenuItem(value: 500, child: Text('Últimas 500')),
              PopupMenuItem(value: 1000, child: Text('Últimas 1000')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : () => _loadData(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    if (_loading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('Error al cargar datos', style: DashboardTextStyles.deviceTitle),
            const SizedBox(height: 8),
            Text(_error!, style: DashboardTextStyles.sensorMeta),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final data = _data!;
    final readings = data.readings;

    if (readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Sin lecturas', style: DashboardTextStyles.deviceTitle),
            const SizedBox(height: 8),
            Text(
              'No hay datos para este sensor aún.',
              style: DashboardTextStyles.sensorMeta,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: DashboardColors.cardBackground,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${readings.length} lecturas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_lastFetchedAt != null)
                      Text(
                        'Actualizado: ${DateFormat('HH:mm:ss').format(_lastFetchedAt!)}',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(8),
            color: DashboardColors.cardBackground,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: RawSensorChart(readings: readings, unit: widget.unit),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            color: DashboardColors.cardBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Historial de lecturas',
                    style: DashboardTextStyles.deviceTitle,
                  ),
                ),
                Expanded(
                  child: RawReadingsList(
                    readings: readings,
                    unit: widget.unit,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
