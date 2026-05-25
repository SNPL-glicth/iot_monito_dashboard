import 'package:flutter/material.dart';

import '../../../data/models/reading/latest_reading_models.dart';
import '../../styles/dashboard_styles.dart';
import 'dashboard_devices_section.dart';
import 'dashboard_page_models.dart';
import 'dashboard_readings_section.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({
    super.key,
    required this.devicesSection,
  });

  final ValueNotifier<SectionSnapshot<DevicesSectionData>> devicesSection;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final hPad = isWide ? constraints.maxWidth * 0.15 : 16.0;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<SectionSnapshot<DevicesSectionData>>(
                    valueListenable: devicesSection,
                    builder: (context, snapshot, _) {
                      if (snapshot.loading && snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.error != null && snapshot.data == null) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final data = snapshot.data;
                      if (data == null || data.devices.isEmpty) {
                        return const Text('No hay dispositivos registrados.');
                      }
                      return DashboardDevicesSection(
                        devices: data.devices,
                        latestReadings: data.latestReadings,
                        statusBySensorId: data.statusBySensorId,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<SectionSnapshot<DevicesSectionData>>(
                    valueListenable: devicesSection,
                    builder: (context, snapshot, _) {
                      if (snapshot.loading && snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.error != null && snapshot.data == null) {
                        return Text('Error: ${snapshot.error}', style: DashboardTextStyles.error);
                      }
                      final readings = snapshot.data?.latestReadings ?? const <LatestSensorReadingViewModel>[];
                      return DashboardReadingsSection(readings: readings);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
