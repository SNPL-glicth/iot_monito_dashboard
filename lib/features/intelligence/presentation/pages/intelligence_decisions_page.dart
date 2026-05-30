import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../data/intelligence_models.dart';
import '../../data/intelligence_repository.dart';
import '../../data/intelligence_prefetch_service.dart';
import '../widgets/intelligence_decisions_helpers.dart';
import '../widgets/decisions/decisions_filters_header.dart';
import '../widgets/decisions/decisions_content.dart';
import '../../../../../core/theme/design_colors.dart';


class IntelligenceDecisionsPage extends StatefulWidget {
  const IntelligenceDecisionsPage({super.key});

  @override
  State<IntelligenceDecisionsPage> createState() => _IntelligenceDecisionsPageState();
}

class _IntelligenceDecisionsPageState extends State<IntelligenceDecisionsPage> {
  late final IntelligenceRepository _repo;
  List<DecisionActionViewModel>? _decisions;
  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdated;
  
  String _statusFilter = '';
  String _severityFilter = '';

  @override
  void initState() {
    super.initState();
    _repo = IntelligenceRepository(ApiClient());
    _loadDecisions();
  }

  Future<void> _loadDecisions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<DecisionActionViewModel> decisions;

      // Tarea 3: Intentar consumir prefetch de decisiones
      final prefetchFuture = IntelligencePrefetchService().consumeDecisions();
      if (prefetchFuture != null) {
        decisions = await prefetchFuture;
        // Invalidar cache si cambiaron filtros
        if (_statusFilter.isNotEmpty || _severityFilter.isNotEmpty) {
          decisions = decisions.where((d) {
            final statusMatch = _statusFilter.isEmpty || d.status == _statusFilter;
            final severityMatch = _severityFilter.isEmpty || d.severity == _severityFilter;
            return statusMatch && severityMatch;
          }).toList();
        }
      } else {
        decisions = await _repo.fetchDecisions(
          status: _statusFilter.isEmpty ? null : _statusFilter,
          severity: _severityFilter.isEmpty ? null : _severityFilter,
        );
      }

      if (mounted) {
        setState(() {
          _decisions = decisions;
          _isLoading = false;
          _lastUpdated = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(DecisionActionViewModel decision, String newStatus) async {
    try {
      await _repo.updateDecisionStatus(decision.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Decisión marcada como ${IntelligenceDecisionsHelpers.statusLabel(newStatus).toLowerCase()}'),
            backgroundColor: DesignColors.green,
          ),
        );
        _loadDecisions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: DesignColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decisiones del Sistema'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDecisions,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header con filtros y última actualización
            SliverToBoxAdapter(
              child: DecisionsFiltersHeader(
                lastUpdated: _lastUpdated,
                statusFilter: _statusFilter,
                severityFilter: _severityFilter,
                onStatusChanged: (value) {
                  setState(() {
                    _statusFilter = value;
                  });
                  _loadDecisions();
                },
                onSeverityChanged: (value) {
                  setState(() {
                    _severityFilter = value;
                  });
                  _loadDecisions();
                },
              ),
            ),
            // Contenido principal
            DecisionsContent(
              isLoading: _isLoading,
              decisions: _decisions,
              error: _error,
              statusFilter: _statusFilter,
              severityFilter: _severityFilter,
              onRetry: _loadDecisions,
              onUpdateStatus: _updateStatus,
            ),
          ],
        ),
      ),
    );
  }

}
