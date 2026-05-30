import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../crm/data/crm_repository.dart';
import '../../../crm/data/models/crm_alerts_models.dart';
import '../widgets/alert_list_view.dart';
import '../widgets/alerts_hub_helpers.dart';
import '../widgets/alerts_hub_widgets.dart';
import 'alert_detail_page.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_text_styles.dart';
import '../../../../core/theme/design_spacing.dart';

/// Página de alertas con paginación e infinite scroll.
///
/// REGLAS DE PRIORIDAD:
/// 1. Alertas críticas (rojo) - siempre primero
/// 2. Alertas warning (naranja) - segundo
/// 3. Alertas info (azul) - tercero
class AlertsHubPage extends StatefulWidget {
  const AlertsHubPage({super.key, required this.role});

  final UserRole role;

  @override
  State<AlertsHubPage> createState() => _AlertsHubPageState();
}

class _AlertsHubPageState extends State<AlertsHubPage> {
  late final CrmRepository _repo;
  final _scrollController = ScrollController();

  final List<CrmAlertHistoryItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;
  static const _pageSize = 20;

  String? _selectedSensorId;
  String? _selectedSensorName;

  @override
  void initState() {
    super.initState();
    _repo = CrmRepository();
    _scrollController.addListener(_onScroll);
    _loadAlerts(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    final pos = _scrollController.position;
    final threshold = pos.maxScrollExtent * 0.8;
    if (pos.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadAlerts({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _items.clear();
        _currentPage = 1;
        _hasMore = true;
      });
    }

    try {
      final response = await _repo.listAlerts(
        sensorId: _selectedSensorId,
        page: 1,
        pageSize: _pageSize,
      );
      final sorted = _sortItems(response.items);
      setState(() {
        _items.addAll(sorted);
        _hasMore = _items.length < response.total;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final response = await _repo.listAlerts(
        sensorId: _selectedSensorId,
        page: nextPage,
        pageSize: _pageSize,
      );
      final sorted = _sortItems(response.items);
      setState(() {
        _items.addAll(sorted);
        _currentPage = nextPage;
        _hasMore = _items.length < response.total;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _loadingMore = false);
    }
  }

  List<CrmAlertHistoryItem> _sortItems(List<CrmAlertHistoryItem> items) {
    return List.from(items)..sort((a, b) {
      final sa = AlertsHubHelpers.severityRank(a.severity);
      final sb = AlertsHubHelpers.severityRank(b.severity);
      if (sa != sb) return sa.compareTo(sb);
      return b.triggeredAt.compareTo(a.triggeredAt);
    });
  }

  void _filterBySensor(String? sensorId, String? sensorName) {
    setState(() {
      _selectedSensorId = sensorId;
      _selectedSensorName = sensorName;
    });
    _loadAlerts(reset: true);
  }

  void _clearFilter() {
    setState(() {
      _selectedSensorId = null;
      _selectedSensorName = null;
    });
    _loadAlerts(reset: true);
  }

  void _refresh() => _loadAlerts(reset: true);

  @override
  Widget build(BuildContext context) {
    final criticalCount = _items.where((a) => a.severity.toLowerCase() == 'critical').length;
    final warningCount = _items.where((a) => a.severity.toLowerCase() == 'warning').length;

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: SafeArea(child: _buildBody(criticalCount, warningCount)),
    );
  }

  Widget _buildBody(int criticalCount, int warningCount) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error cargando alertas: $_error', textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const AlertEmptyState();
    }

    return Column(
      children: [
        if (_selectedSensorId != null)
          AlertSensorFilter(
            sensorName: _selectedSensorName ?? 'Sensor',
            onClear: _clearFilter,
          ),
        if (criticalCount > 0 || warningCount > 0)
          AlertSummary(
            criticalCount: criticalCount,
            warningCount: warningCount,
            totalCount: _items.length,
          ),
        Expanded(
          child: AlertListView(
            items: _items,
            selectedSensorId: _selectedSensorId,
            onFilterBySensor: _filterBySensor,
            onAlertTap: (a) async {
              final sensorId = a.sensorId;
              if (sensorId == null || sensorId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Alerta sin sensor asociado'), backgroundColor: DesignColors.amber),
                );
                return;
              }
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AlertDetailPage(alertId: a.alertId, sensorId: sensorId, role: widget.role),
                ),
              );
              if (mounted) _refresh();
            },
            scrollController: _scrollController,
            footer: _buildFooter(),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }
    if (!_hasMore) {
      return Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Center(
          child: Text('Sin más alertas', style: DesignTextStyles.bodyText),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
