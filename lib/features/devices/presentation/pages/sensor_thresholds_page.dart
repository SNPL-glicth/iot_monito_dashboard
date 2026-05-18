import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../widgets/thresholds/threshold_profile_dialog.dart';
import '../widgets/thresholds/threshold_edit_dialog.dart';
import '../widgets/thresholds/threshold_history_sheet.dart';
import '../widgets/thresholds/threshold_create_dialog.dart';
import '../widgets/thresholds/sensor_info_card.dart';
import '../widgets/thresholds/threshold_profile_card.dart';
import '../widgets/thresholds/threshold_legacy_list.dart';

class SensorThresholdsPage extends StatefulWidget {
  const SensorThresholdsPage({
    super.key,
    required this.role,
    required this.sensorId,
    required this.sensorName,
    required this.sensorType,
    required this.unit,
  });

  final UserRole role;
  final String sensorId;
  final String sensorName;
  final String sensorType;
  final String unit;

  @override
  State<SensorThresholdsPage> createState() => _SensorThresholdsPageState();
}

class _SensorThresholdsPageState extends State<SensorThresholdsPage> {
  late final MonitoringRepository _repo;
  late Future<SensorThresholdProfileViewModel> _profileFuture;
  late Future<List<AlertThresholdViewModel>> _legacyFuture;

  @override
  void initState() {
    super.initState();
    _repo = MonitoringRepository();
    _profileFuture = _repo.fetchSensorThresholdProfile(widget.sensorId);
    _legacyFuture = _repo.fetchSensorThresholds(widget.sensorId);
  }

  void _refresh() {
    setState(() {
      _profileFuture = _repo.fetchSensorThresholdProfile(widget.sensorId);
      _legacyFuture = _repo.fetchSensorThresholds(widget.sensorId);
    });
  }

  Future<void> _editProfile(SensorThresholdProfileViewModel p) async {
    await showThresholdProfileDialog(
      context: context,
      repo: _repo,
      sensorId: widget.sensorId,
      sensorName: widget.sensorName,
      unit: widget.unit,
      profile: p,
      onSaved: _refresh,
    );
  }

  String _formatRule(AlertThresholdViewModel t) {
    final min = t.thresholdValueMin;
    final max = t.thresholdValueMax;
    final u = widget.unit.trim();

    final unitSuffix = u.isEmpty ? '' : ' $u';

    switch (t.conditionType) {
      case 'greater_than':
        return 'Valor > ${min ?? '-'}$unitSuffix';
      case 'less_than':
        return 'Valor < ${min ?? '-'}$unitSuffix';
      case 'equal_to':
        return 'Valor = ${min ?? '-'}$unitSuffix';
      case 'out_of_range':
        return 'Fuera de rango (${min ?? '-'} – ${max ?? '-'})$unitSuffix';
      default:
        return 'Regla: ${t.conditionType} (min=$min max=$max)$unitSuffix';
    }
  }

  Future<void> _showHistory(AlertThresholdViewModel t) async {
    await showThresholdHistorySheet(
      context: context,
      repo: _repo,
      threshold: t,
    );
  }

  Future<void> _editThreshold(AlertThresholdViewModel t) async {
    await showThresholdEditDialog(
      context: context,
      repo: _repo,
      sensorName: widget.sensorName,
      unit: widget.unit,
      threshold: t,
      onSaved: _refresh,
    );
  }

  Future<void> createThreshold() async {
    await showThresholdCreateDialog(
      context: context,
      repo: _repo,
      sensorId: widget.sensorId,
      sensorName: widget.sensorName,
      unit: widget.unit,
      onCreated: _refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Sensor'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: FutureBuilder<List<AlertThresholdViewModel>>(
        future: _legacyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final legacyRows = snapshot.data ?? const <AlertThresholdViewModel>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SensorInfoCard(
                sensorName: widget.sensorName,
                sensorType: widget.sensorType,
                sensorId: widget.sensorId,
                unit: widget.unit,
              ),
              const SizedBox(height: 12),
              ThresholdProfileCard(
                future: _profileFuture,
                unit: widget.unit,
                canEdit: canEdit,
                onEdit: _editProfile,
              ),
              const SizedBox(height: 12),
              ThresholdLegacyList(
                thresholds: legacyRows,
                canEdit: canEdit,
                onEdit: _editThreshold,
                onHistory: _showHistory,
                formatRule: _formatRule,
              ),
            ],
          );
        },
      ),
    );
  }
}
