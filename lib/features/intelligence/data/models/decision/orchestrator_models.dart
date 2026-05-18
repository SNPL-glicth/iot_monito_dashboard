/// Modelos del orquestador
library;

import 'analysis_models.dart';
import 'task_signal_models.dart';

/// Resumen de spikes
class SpikesSummaryViewModel {
  const SpikesSummaryViewModel({
    required this.totalSpikes,
    required this.recurringSpikes,
    required this.criticalSpikes,
    required this.dominantSpikeType,
  });

  final int totalSpikes;
  final int recurringSpikes;
  final int criticalSpikes;
  final String? dominantSpikeType;

  factory SpikesSummaryViewModel.fromJson(Map<String, dynamic> json) {
    return SpikesSummaryViewModel(
      totalSpikes: _parseInt(json['totalSpikes']),
      recurringSpikes: _parseInt(json['recurringSpikes']),
      criticalSpikes: _parseInt(json['criticalSpikes']),
      dominantSpikeType: json['dominantSpikeType']?.toString(),
    );
  }
}

/// Estadísticas del orquestador
class OrchestratorStatsViewModel {
  const OrchestratorStatsViewModel({
    required this.decisionsLast1h,
    required this.decisionsLast24h,
    required this.avgProcessingTimeMs,
    required this.deduplicationRate,
    required this.eventsProcessedLast24h,
  });

  final int decisionsLast1h;
  final int decisionsLast24h;
  final int avgProcessingTimeMs;
  final double deduplicationRate;
  final int eventsProcessedLast24h;

  factory OrchestratorStatsViewModel.fromJson(Map<String, dynamic> json) {
    return OrchestratorStatsViewModel(
      decisionsLast1h: _parseInt(json['decisionsLast1h']),
      decisionsLast24h: _parseInt(json['decisionsLast24h']),
      avgProcessingTimeMs: _parseInt(json['avgProcessingTimeMs']),
      deduplicationRate: _parseDouble(json['deduplicationRate']),
      eventsProcessedLast24h: _parseInt(json['eventsProcessedLast24h']),
    );
  }
}

/// Insights completos del orquestador
class OrchestratorInsightsViewModel {
  const OrchestratorInsightsViewModel({
    required this.timestamp,
    required this.situationSummary,
    required this.whatMlShouldKnow,
    required this.whatIsNotBeingConsidered,
    required this.overallHealthScore,
    required this.mlReadinessScore,
    required this.changeAnalyses,
    required this.dominantChangeType,
    required this.spikeAnalyses,
    required this.spikesSummary,
    required this.taskContexts,
    required this.priorityTasks,
    required this.signalAnalyses,
    required this.weakSignalsCount,
    required this.orchestratorStats,
    required this.recommendations,
    required this.warnings,
  });

  final String timestamp;
  final String situationSummary;
  final String whatMlShouldKnow;
  final String whatIsNotBeingConsidered;
  final double overallHealthScore;
  final double mlReadinessScore;
  final List<ChangeAnalysisViewModel> changeAnalyses;
  final String? dominantChangeType;
  final List<SpikeAnalysisViewModel> spikeAnalyses;
  final SpikesSummaryViewModel spikesSummary;
  final List<TaskContextViewModel> taskContexts;
  final List<String> priorityTasks;
  final List<SignalAnalysisViewModel> signalAnalyses;
  final int weakSignalsCount;
  final OrchestratorStatsViewModel orchestratorStats;
  final List<String> recommendations;
  final List<String> warnings;

  factory OrchestratorInsightsViewModel.fromJson(Map<String, dynamic> json) {
    final changeRaw = json['changeAnalyses'];
    List<ChangeAnalysisViewModel> changes = [];
    if (changeRaw is List) {
      changes = changeRaw
          .whereType<Map>()
          .map((e) => ChangeAnalysisViewModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    final spikeRaw = json['spikeAnalyses'];
    List<SpikeAnalysisViewModel> spikes = [];
    if (spikeRaw is List) {
      spikes = spikeRaw
          .whereType<Map>()
          .map((e) => SpikeAnalysisViewModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    final taskRaw = json['taskContexts'];
    List<TaskContextViewModel> tasks = [];
    if (taskRaw is List) {
      tasks = taskRaw
          .whereType<Map>()
          .map((e) => TaskContextViewModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    final signalRaw = json['signalAnalyses'];
    List<SignalAnalysisViewModel> signals = [];
    if (signalRaw is List) {
      signals = signalRaw
          .whereType<Map>()
          .map((e) => SignalAnalysisViewModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return OrchestratorInsightsViewModel(
      timestamp: '${json['timestamp'] ?? ''}',
      situationSummary: '${json['situationSummary'] ?? ''}',
      whatMlShouldKnow: '${json['whatMlShouldKnow'] ?? ''}',
      whatIsNotBeingConsidered: '${json['whatIsNotBeingConsidered'] ?? ''}',
      overallHealthScore: _parseDouble(json['overallHealthScore']),
      mlReadinessScore: _parseDouble(json['mlReadinessScore']),
      changeAnalyses: changes,
      dominantChangeType: json['dominantChangeType']?.toString(),
      spikeAnalyses: spikes,
      spikesSummary: SpikesSummaryViewModel.fromJson(
        json['spikesSummary'] is Map ? (json['spikesSummary'] as Map).cast<String, dynamic>() : {},
      ),
      taskContexts: tasks,
      priorityTasks: _parseStringList(json['priorityTasks']),
      signalAnalyses: signals,
      weakSignalsCount: _parseInt(json['weakSignalsCount']),
      orchestratorStats: OrchestratorStatsViewModel.fromJson(
        json['orchestratorStats'] is Map ? (json['orchestratorStats'] as Map).cast<String, dynamic>() : {},
      ),
      recommendations: _parseStringList(json['recommendations']),
      warnings: _parseStringList(json['warnings']),
    );
  }

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasSpikes => spikesSummary.totalSpikes > 0;
  bool get hasCriticalSpikes => spikesSummary.criticalSpikes > 0;
  bool get hasWeakSignals => weakSignalsCount > 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final s = '$value';
  return double.tryParse(s) ?? 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final s = '$value';
  return int.tryParse(s) ?? 0;
}

List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => '$e').toList();
  }
  return [];
}
