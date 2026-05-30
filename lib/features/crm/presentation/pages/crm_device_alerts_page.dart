import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/user_role.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_alerts_models.dart';
import '../../data/models/crm_devices_models.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


class CrmDeviceAlertsPage extends StatefulWidget {
  const CrmDeviceAlertsPage({
    super.key,
    required this.role,
    required this.deviceId,
    this.deviceNameHint,
  });

  final UserRole role;
  final int deviceId;
  final String? deviceNameHint;

  @override
  State<CrmDeviceAlertsPage> createState() => _CrmDeviceAlertsPageState();
}

class _CrmDeviceAlertsPageState extends State<CrmDeviceAlertsPage> {
  late final CrmRepository _repo;
  late Future<CrmPagedResponse<CrmAlertHistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _repo = CrmRepository();
    _future = _repo.listAlerts(deviceId: widget.deviceId.toString(), pageSize: 200);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repo.listAlerts(deviceId: widget.deviceId.toString(), pageSize: 200);
    });
    await _future;
  }

  String _fmt(String raw) {
    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(iso.toLocal());
    }
    return raw;
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return DesignColors.red;
      case 'warning':
        return DesignColors.amber;
      case 'info':
        return DesignColors.cyan;
      default:
        return DesignColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.deviceNameHint ?? 'Alertas del dispositivo #${widget.deviceId}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<CrmPagedResponse<CrmAlertHistoryItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error cargando alertas: ${snapshot.error}',
                  style: DesignTextStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
              );
            }

            final page = snapshot.data;
            final items = page?.items ?? const <CrmAlertHistoryItem>[];
            if (items.isEmpty) {
              return Center(
                child: Text('No hay alertas registradas.', style: DesignTextStyles.bodyText),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(DesignSpacing.lg),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final a = items[index];
                final when = _fmt(a.triggeredAt);

                final status = a.status.trim().isEmpty ? '-' : a.status;
                final threshold = (a.thresholdName ?? '').trim().isEmpty ? 'Alerta' : a.thresholdName!.trim();

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: _severityColor(a.severity)),
                    title: Text(
                      '$threshold (${a.severity.toUpperCase()})',
                      style: DesignTextStyles.bodyText,
                    ),
                    subtitle: Text(
                      'Estado: $status\n'
                      'Valor: ${a.triggeredValue}${(a.unit ?? '').trim().isEmpty ? '' : ' ${a.unit}'}\n'
                      'Fecha: $when',
                      style: DesignTextStyles.bodyText,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
