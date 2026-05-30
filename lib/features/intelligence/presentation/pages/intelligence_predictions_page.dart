import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../data/intelligence_models.dart';
import '../../data/intelligence_repository.dart';
import '../widgets/predictions/prediction_card.dart';
import '../widgets/predictions/prediction_skeleton.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../../../core/theme/design_text_styles.dart';

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
    _future = _loadPredictions();
  }

  Future<List<PredictionSummaryViewModel>> _loadPredictions() async {
    try {
      return await _repo.fetchLatestPredictions();
    } catch (e) {
      // Propagar error al FutureBuilder para que muestre estado de error
      return Future.error(e);
    }
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
          setState(() {
            _future = _loadPredictions();
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
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  child: Text(
                    'Error cargando predicciones: ${snapshot.error}',
                    style: DesignTextStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final items = snapshot.data ?? const <PredictionSummaryViewModel>[];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  child: Text(
                    'No hay predicciones disponibles en este momento.',
                    style: DesignTextStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(DesignSpacing.lg),
              itemCount: items.length,
              itemBuilder: (context, index) => PredictionCard(
                prediction: items[index],
                formatDateTime: _formatDateTime,
              ),
            );
          },
        ),
      ),
    ),
    );
  }
}
