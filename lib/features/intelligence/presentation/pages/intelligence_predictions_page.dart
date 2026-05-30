import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/zenin_colors.dart';
import '../../data/intelligence_models.dart';
import '../../data/intelligence_repository.dart';
import '../../domain/prediction_severity.dart';
import '../widgets/predictions/filter_bar.dart';
import '../widgets/predictions/prediction_card.dart';
import '../widgets/predictions/prediction_skeleton.dart';
import '../widgets/predictions/summary_bar.dart';

class IntelligencePredictionsPage extends StatefulWidget {
  const IntelligencePredictionsPage({super.key});

  @override
  State<IntelligencePredictionsPage> createState() => _IntelligencePredictionsPageState();
}

class _IntelligencePredictionsPageState extends State<IntelligencePredictionsPage> {
  late final IntelligenceRepository _repo;
  late Future<List<PredictionSummaryViewModel>> _future;
  String _activeFilter = 'all';
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _repo = IntelligenceRepository(ApiClient());
    _future = _loadPredictions();
  }

  Future<List<PredictionSummaryViewModel>> _loadPredictions() async {
    try {
      final result = await _repo.fetchLatestPredictions();
      _lastUpdated = DateTime.now();
      return result;
    } catch (e) {
      return Future.error(e);
    }
  }

  String _formatDateTime(String raw) {
    if (raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  List<PredictionSummaryViewModel> _applyFilter(List<PredictionSummaryViewModel> items) {
    if (_activeFilter == 'all') return items;
    return items.where((p) {
      final level = PredictionSeverity.fromString(p.severity);
      if (_activeFilter == 'alerts') {
        return level == SeverityLevel.critical ||
            level == SeverityLevel.high ||
            level == SeverityLevel.medium;
      }
      if (_activeFilter == 'normal') {
        return level == SeverityLevel.none || level == SeverityLevel.low;
      }
      return true;
    }).toList();
  }

  void _onFilterChanged(String filter) {
    setState(() => _activeFilter = filter);
  }

  void _navigateToSensorDetail(PredictionSummaryViewModel p) {
    if (p.sensorId.isEmpty) return;
    Navigator.pushNamed(context, '/sensor/${p.sensorId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZeninColors.bgBase,
      body: SafeArea(
        child: RefreshIndicator(
          color: ZeninColors.green,
          backgroundColor: ZeninColors.bgCard,
          onRefresh: () async {
            setState(() => _future = _loadPredictions());
            await _future;
          },
          child: FutureBuilder<List<PredictionSummaryViewModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _Body(
                  child: SizedBox(
                    height: 600,
                    child: PredictionsSkeletonList(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _Body(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error cargando predicciones: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ZeninColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              final allItems = snapshot.data ?? const <PredictionSummaryViewModel>[];
              final filtered = _applyFilter(allItems);
              final total = allItems.length;
              final normalCount = allItems.where((p) {
                final l = PredictionSeverity.fromString(p.severity);
                return l == SeverityLevel.none || l == SeverityLevel.low;
              }).length;
              final warningCount = allItems.where((p) {
                final l = PredictionSeverity.fromString(p.severity);
                return l == SeverityLevel.medium || l == SeverityLevel.high;
              }).length;
              final criticalCount = allItems.where((p) {
                final l = PredictionSeverity.fromString(p.severity);
                return l == SeverityLevel.critical;
              }).length;

              return _Body(
                lastUpdated: _lastUpdated,
                totalSensors: total,
                normalCount: normalCount,
                warningCount: warningCount,
                criticalCount: criticalCount,
                activeFilter: _activeFilter,
                onFilterChanged: _onFilterChanged,
                child: filtered.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No hay predicciones disponibles para este filtro.',
                            style: TextStyle(
                              fontSize: 12,
                              color: ZeninColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(1),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                          childAspectRatio: 1.35,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => PredictionCard(
                          prediction: filtered[index],
                          formatDateTime: _formatDateTime,
                          onViewHistory: () => _navigateToSensorDetail(filtered[index]),
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.child,
    this.lastUpdated,
    this.totalSensors,
    this.normalCount,
    this.warningCount,
    this.criticalCount,
    this.activeFilter,
    this.onFilterChanged,
  });

  final Widget child;
  final DateTime? lastUpdated;
  final int? totalSensors;
  final int? normalCount;
  final int? warningCount;
  final int? criticalCount;
  final String? activeFilter;
  final ValueChanged<String>? onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Predicciones del sistema',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ZeninColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalSensors == null
                      ? _formatLastUpdated()
                      : '${_formatLastUpdated()} · $totalSensors sensores',
                  style: const TextStyle(
                    fontSize: 11,
                    color: ZeninColors.textDim,
                  ),
                ),
                const SizedBox(height: 12),
                if (onFilterChanged != null)
                  FilterBarWidget(onFilterChanged: onFilterChanged!),
              ],
            ),
          ),
        ),
        if (totalSensors != null &&
            normalCount != null &&
            warningCount != null &&
            criticalCount != null)
          SliverToBoxAdapter(
            child: SummaryBarWidget(
              total: totalSensors!,
              normalCount: normalCount!,
              warningCount: warningCount!,
              criticalCount: criticalCount!,
            ),
          ),
        SliverToBoxAdapter(
          child: child,
        ),
      ],
    );
  }

  String _formatLastUpdated() {
    if (lastUpdated == null) return 'Actualizando...';
    return DateFormat('dd/MM/yyyy HH:mm').format(lastUpdated!.toLocal());
  }
}
