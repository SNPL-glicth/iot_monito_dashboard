import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../../../core/presentation/widgets/app_loading_widget.dart';
import '../../data/metrics_repository.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';

/// Página de métricas del servidor - Solo lectura
class ServerMetricsPage extends StatefulWidget {
  const ServerMetricsPage({super.key});

  @override
  State<ServerMetricsPage> createState() => _ServerMetricsPageState();
}

class _ServerMetricsPageState extends State<ServerMetricsPage> {
  final MetricsRepository _repository = MetricsRepository();
  
  AllMetrics? _metrics;
  bool _loading = true;
  String? _error;
  DateTime? _lastUpdatedAt;
  Timer? _refreshTimer;
  StreamSubscription<void>? _lifecyclePauseSub;
  StreamSubscription<void>? _lifecycleResumeSub;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _startPolling();

    _lifecyclePauseSub = AppLifecycleService().onAppPaused.listen((_) {
      _refreshTimer?.cancel();
    });
    _lifecycleResumeSub = AppLifecycleService().onAppResumed.listen((_) {
      _startPolling();
      _loadMetrics();
    });
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _loadMetrics();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _lifecyclePauseSub?.cancel();
    _lifecycleResumeSub?.cancel();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    try {
      final metrics = await _repository.fetchAllMetrics();
      if (!mounted) return;
      setState(() {
        _metrics = metrics;
        _loading = false;
        _error = null;
        _lastUpdatedAt = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Métricas del Servidor'),
            if (_lastUpdatedAt != null)
              Text(
                'Actualizado: ${_lastUpdatedAt!.hour.toString().padLeft(2, '0')}:${_lastUpdatedAt!.minute.toString().padLeft(2, '0')}:${_lastUpdatedAt!.second.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: DesignColors.textPrimary),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMetrics,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _metrics == null) {
      return const AppLoadingWidget();
    }

    if (_error != null && _metrics == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: DesignColors.red),
            SizedBox(height: 12),
            Text('Error: $_error', textAlign: TextAlign.center),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadMetrics,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final m = _metrics!;

    return RefreshIndicator(
      onRefresh: _loadMetrics,
      child: ListView(
        padding: EdgeInsets.all(DesignSpacing.lg),
        children: [
          // Sistema
          _buildSectionHeader(Icons.computer, 'Sistema'),
          _buildMetricCard(
            children: [
              _buildMetricRow('Host', m.system.hostname),
              _buildMetricRow('Plataforma', m.system.platformType),
              _buildMetricRow('CPU', '${m.system.cpuCores} cores'),
              _buildProgressRow('CPU', m.system.cpuUsagePercent, Colors.blueAccent),
              _buildProgressRow('RAM', m.system.memoryUsagePercent, Colors.purpleAccent),
              _buildMetricRow('RAM Usado', '${m.system.memoryUsedMB} / ${m.system.memoryTotalMB} MB'),
              _buildMetricRow('Uptime Sistema', _formatUptime(m.system.uptimeSystem)),
              _buildMetricRow('Uptime Proceso', _formatUptime(m.system.uptimeProcess)),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Ingesta
          _buildSectionHeader(Icons.speed, 'Ingesta (Tiempo Real)'),
          _buildMetricCard(
            children: [
              _buildHighlightRow('Eventos/seg', m.ingest.eventsPerSecond.toStringAsFixed(2), Colors.tealAccent),
              _buildMetricRow('Lecturas (5 min)', _formatNumber(m.ingest.readingsLast5min)),
              _buildMetricRow('Alertas (5 min)', m.ingest.alertsLast5min.toString()),
              _buildMetricRow('ML Events (5 min)', m.ingest.mlEventsLast5min.toString()),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Base de datos
          _buildSectionHeader(Icons.storage, 'Base de Datos'),
          _buildMetricCard(
            children: [
              _buildMetricRow('Sensores', '${m.database.sensorsActive} activos / ${m.database.sensorsTotal} total'),
              _buildMetricRow('Lecturas (24h)', _formatNumber(m.database.readingsLast24h)),
              _buildMetricRow('Lecturas (1h)', _formatNumber(m.database.readingsLastHour)),
              _buildMetricRow('Alertas activas', m.database.alertsActive.toString()),
              _buildMetricRow('Alertas (24h)', m.database.alertsLast24h.toString()),
              _buildMetricRow('ML Events activos', m.database.mlEventsActive.toString()),
              _buildMetricRow('ML Events (24h)', m.database.mlEventsLast24h.toString()),
              _buildMetricRow('Predicciones (24h)', m.database.predictionsLast24h.toString()),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Footer con timestamp
          Center(
            child: Text(
              'Última actualización: ${m.system.timestamp}',
              style: const TextStyle(color: DesignColors.textDim, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: DesignColors.textPrimary),
          SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({required List<Widget> children}) {
    return Card(
      color: const Color(0xFF1E1E2E),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: DesignColors.textPrimary)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHighlightRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: DesignColors.textPrimary, fontSize: 15)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double percent, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: DesignColors.textPrimary)),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: percent > 80 ? DesignColors.red : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(
                percent > 80 ? DesignColors.red : color,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
