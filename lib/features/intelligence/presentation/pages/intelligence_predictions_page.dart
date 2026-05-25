import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../data/intelligence_models.dart';
import '../../data/intelligence_repository.dart';
import '../widgets/predictions/prediction_card.dart';
import '../widgets/predictions/prediction_skeleton.dart';

class IntelligencePredictionsPage extends StatefulWidget {
  const IntelligencePredictionsPage({super.key});

  @override
  State<IntelligencePredictionsPage> createState() => _IntelligencePredictionsPageState();
}

class _IntelligencePredictionsPageState extends State<IntelligencePredictionsPage> {
  late final IntelligenceRepository _repo;
  late Future<List<PredictionSummaryViewModel>> _future;

  @override
  void initState() {
    super.initState();
    _repo = IntelligenceRepository(ApiClient());
    _future = _repo.fetchLatestPredictions();
  }

  String _formatDateTime(String raw) {
    if (raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicciones del sistema'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _future = _repo.fetchLatestPredictions();
          });
          await _future;
        },
        child: FutureBuilder<List<PredictionSummaryViewModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const PredictionsSkeletonList();
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error cargando predicciones: ${snapshot.error}',
                    style: DashboardTextStyles.error,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final items = snapshot.data ?? const <PredictionSummaryViewModel>[];
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No hay predicciones disponibles en este momento.',
                    style: DashboardTextStyles.sensorMeta,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) => PredictionCard(
                prediction: items[index],
                formatDateTime: _formatDateTime,
              ),
            );
          },
        ),
      ),
    );
  }
}
