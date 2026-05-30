import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../alerts/data/state_aware_alert_repository.dart';
import '../../../alerts/data/models/alert_with_state.dart';
import '../widgets/warnings/warning_alert_card.dart';
import '../widgets/warnings/warning_counters_header.dart';
import '../widgets/warnings/warning_error_state.dart';
import '../widgets/warnings/warning_empty_state.dart';
import '../../../../core/theme/design_spacing.dart';

/// Página de advertencias inteligentes con UI modernizada estilo trading
/// 
/// MEJORAS IMPLEMENTADAS:
/// - Deduplicación de predicciones por sensor (solo la más reciente)
/// - Agrupación por sensor para mostrar independencia
/// - Estilos modernos trading-style
/// - Contadores que muestran solo alertas activas
class IntelligenceWarningsPage extends StatefulWidget {
  const IntelligenceWarningsPage({
    super.key,
    required this.role,
  });

  final UserRole role;

  @override
  State<IntelligenceWarningsPage> createState() => _IntelligenceWarningsPageState();
}

class _IntelligenceWarningsPageState extends State<IntelligenceWarningsPage> {
  late final StateAwareAlertRepository _repository;
  late Future<List<AlertWithState>> _future;
  
  // Contadores reactivos
  int _totalActive = 0;
  int _criticalCount = 0;
  int _warningCount = 0;

  @override
  void initState() {
    super.initState();
    _repository = StateAwareAlertRepository();
    _loadData();
  }

  void _loadData() {
    // Usar deduplicación por sensor para evitar acumulación
    _future = _repository.fetchDeduplicatedMlAlerts(limit: 50);
    _future.then((alerts) {
      if (mounted) {
        setState(() {
          _totalActive = alerts.where((a) => a.requiresAttention).length;
          _criticalCount = alerts.where((a) => 
            a.requiresAttention && a.severity.toLowerCase() == 'critical'
          ).length;
          _warningCount = alerts.where((a) => 
            a.requiresAttention && a.severity.toLowerCase() == 'warning'
          ).length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advertencias Inteligentes'),
        actions: [
          // Indicador de estado en tiempo real
          Container(
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.tealAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology, size: 14, color: Colors.tealAccent.withValues(alpha: 0.8)),
                SizedBox(width: 4),
                Text(
                  'ML ACTIVO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.tealAccent.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con contadores estilo trading
          WarningCountersHeader(
            totalActive: _totalActive,
            criticalCount: _criticalCount,
            warningCount: _warningCount,
          ),
          
          // Lista de alertas
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadData();
                await _future;
              },
              child: FutureBuilder<List<AlertWithState>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return WarningErrorState(error: snapshot.error.toString());
                  }

                  final items = snapshot.data ?? const <AlertWithState>[];
                  if (items.isEmpty) {
                    return const WarningEmptyState();
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(DesignSpacing.md),
                    itemCount: items.length,
                    itemBuilder: (context, index) => WarningAlertCard(alert: items[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}
