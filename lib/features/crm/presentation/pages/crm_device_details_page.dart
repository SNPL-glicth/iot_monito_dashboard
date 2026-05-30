import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/user_role.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_devices_models.dart';
import '../widgets/device_detail/device_detail_content.dart';
import '../../../../core/theme/design_spacing.dart';

class CrmDeviceDetailsPage extends StatefulWidget {
  const CrmDeviceDetailsPage({
    super.key,
    required this.role,
    required this.deviceId,
    this.deviceNameHint,
  });

  final UserRole role;
  final int deviceId;
  final String? deviceNameHint;

  @override
  State<CrmDeviceDetailsPage> createState() => _CrmDeviceDetailsPageState();
}

class _CrmDeviceDetailsPageState extends State<CrmDeviceDetailsPage> {
  late final CrmRepository _repo;
  late Future<CrmDeviceProfileFullResponse> _future;

  @override
  void initState() {
    super.initState();
    _repo = CrmRepository();
    _future = _repo.getDeviceProfileFull(deviceId: widget.deviceId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repo.getDeviceProfileFull(deviceId: widget.deviceId);
    });
    await _future;
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(iso.toLocal());
    }
    return raw;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceNameHint ?? 'Dispositivo #${widget.deviceId}'),
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: FutureBuilder<CrmDeviceProfileFullResponse>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final data = snapshot.data;
              if (data == null) {
                return const Center(child: Text('Sin datos.'));
              }

              return DeviceDetailContent(
                data: data,
                role: widget.role,
                deviceId: widget.deviceId,
                formatDateTime: _formatDateTime,
              );
            },
          ),
        ),
      ),
    );
  }

}
