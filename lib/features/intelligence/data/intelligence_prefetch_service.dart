import '../../../core/network/api_client.dart';
import 'intelligence_models.dart';
import 'intelligence_repository.dart';

/// Servicio de prefetch para el módulo de inteligencia.
///
/// Inicia cargas en background cuando el usuario entra a la sección
/// de inteligencia, para que las subpáginas (decisiones) estén listas.
class IntelligencePrefetchService {
  static final IntelligencePrefetchService _instance = IntelligencePrefetchService._internal();
  factory IntelligencePrefetchService() => _instance;
  IntelligencePrefetchService._internal();

  late final IntelligenceRepository _repo;
  Future<List<DecisionActionViewModel>>? _decisionsFuture;

  void initialize({ApiClient? client}) {
    _repo = IntelligenceRepository(client ?? ApiClient());
  }

  /// Prefetch de decisiones recomendadas. Si ya está en vuelo, reutiliza.
  Future<List<DecisionActionViewModel>> prefetchDecisions() {
    _decisionsFuture ??= _repo.fetchDecisions();
    return _decisionsFuture!;
  }

  /// Consumir el prefetch (para pasarlo a IntelligenceDecisionsPage).
  Future<List<DecisionActionViewModel>>? consumeDecisions() {
    final future = _decisionsFuture;
    _decisionsFuture = null;
    return future;
  }

  bool get hasPendingDecisions => _decisionsFuture != null;

  void invalidate() {
    _decisionsFuture = null;
  }
}
