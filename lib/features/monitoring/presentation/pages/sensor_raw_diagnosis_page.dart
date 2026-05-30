import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/auth/user_role.dart';
import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/presentation/widgets/app_loading_widget.dart';
import '../../data/models/monitoring_view_models.dart';
import '../../data/monitoring_repository.dart';
import '../widgets/raw_diagnosis/raw_diagnosis_empty_state.dart';
import '../widgets/raw_diagnosis/raw_diagnosis_error_widget.dart';
import '../widgets/raw_diagnosis/raw_diagnosis_success_body.dart';
import '../../../../../core/theme/design_colors.dart';



/// Página de diagnóstico con datos crudos sin agregación.
class SensorRawDiagnosisPage extends StatefulWidget {
  const SensorRawDiagnosisPage({
    super.key,
    required this.role,
    required this.sensorId,
    required this.sensorName,
    required this.unit,
  });

  final UserRole role;
  final String sensorId;
  final String sensorName;
  final String unit;

  @override
  State<SensorRawDiagnosisPage> createState() => _SensorRawDiagnosisPageState();
}

class _SensorRawDiagnosisPageState extends State<SensorRawDiagnosisPage> {
  late final MonitoringRepository _repo;

  RawSensorReadingsViewModel? _data;
  bool _loading = true;
  int? _errorStatusCode;
  String? _errorMessage;
  Timer? _poller;
  DateTime? _lastFetchedAt;
  int _limit = 200;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<void>? _lifecyclePauseSub;
  StreamSubscription<void>? _lifecycleResumeSub;

  @override
  void initState() {
    super.initState();
    _repo = MonitoringRepository();
    _loadData();
    _startPolling();

    _lifecyclePauseSub = AppLifecycleService().onAppPaused.listen((_) {
      _poller?.cancel();
    });
    _lifecycleResumeSub = AppLifecycleService().onAppResumed.listen((_) {
      _startPolling();
      _loadData(silent: true);
    });
  }

  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _loadData(silent: true);
    });
  }

  @override
  void dispose() {
    _poller?.cancel();
    _lifecyclePauseSub?.cancel();
    _lifecycleResumeSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _loadData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _errorStatusCode = null;
        _errorMessage = null;
      });
    }

    try {
      final data = await _repo.fetchRawSensorReadings(widget.sensorId, limit: _limit);
      if (!mounted) return;

      setState(() {
        _data = data;
        _loading = false;
        _lastFetchedAt = DateTime.now();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorStatusCode = e.statusCode;
        _errorMessage = e.body.isNotEmpty ? e.body : e.toString();
      });
    } on ApiTimeoutException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorStatusCode = 408;
        _errorMessage = e.toString();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorStatusCode = null;
        _errorMessage = e.toString();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.background,
      appBar: AppBar(
        backgroundColor: DesignColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diagnóstico: ${widget.sensorName}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Datos crudos en tiempo real',
                style: TextStyle(fontSize: 12, color: DesignColors.textPrimary)),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Límite de lecturas',
            onSelected: (value) {
              setState(() => _limit = value);
              _loadData();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 100, child: Text('Últimas 100')),
              PopupMenuItem(value: 200, child: Text('Últimas 200')),
              PopupMenuItem(value: 500, child: Text('Últimas 500')),
              PopupMenuItem(value: 1000, child: Text('Últimas 1000')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : () => _loadData(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _data == null) {
      return const AppLoadingWidget();
    }

    if (_errorMessage != null && _data == null) {
      return RawDiagnosisErrorWidget(
        statusCode: _errorStatusCode,
        message: _errorMessage!,
        onRetry: _loadData,
      );
    }

    final readings = _data!.readings;

    if (readings.isEmpty) return const RawDiagnosisEmptyState();

    return RawDiagnosisSuccessBody(
      readings: readings,
      unit: widget.unit,
      lastFetchedAt: _lastFetchedAt,
      isLoading: _loading,
      scrollController: _scrollController,
    );
  }
}
