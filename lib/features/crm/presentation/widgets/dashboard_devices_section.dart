import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../../../core/theme/design_text_styles.dart';
import '../../../../features/devices/presentation/widgets/device_list.dart';
import '../../data/models/crm_devices_models.dart';

class DashboardDevicesSection extends StatelessWidget {
  const DashboardDevicesSection({
    super.key,
    required this.devices,
    this.expandedDeviceId,
    required this.onToggle,
    required this.onViewDetail,
    this.isLoading = false,
  });

  final List<CrmDeviceSummary> devices;
  final String? expandedDeviceId;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onViewDetail;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Devices'),
          SizedBox(height: DesignSpacing.md),
          _SkeletonCard(),
          SizedBox(height: DesignSpacing.md),
          _SkeletonCard(),
        ],
      );
    }

    if (devices.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Devices'),
          SizedBox(height: DesignSpacing.md),
          Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.xl),
              child: Column(
                children: [
                  Icon(Icons.devices_other,
                      size: 48, color: DesignColors.cyan),
                  SizedBox(height: DesignSpacing.md),
                  Text('No devices connected yet.',
                      style: DesignTextStyles.bodyText),
                  SizedBox(height: DesignSpacing.sm),
                  Text('Add a device to start monitoring.',
                      style: DesignTextStyles.bodyText),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final cardData = devices.map((d) => DeviceCardData(
          deviceId: d.deviceUuid,
          deviceName: d.deviceName,
          uptime: d.lastConnection ?? '-',
          sensorCount: d.sensorCount,
          lastReadingTime: d.lastConnection ?? '-',
          sensors: const [],
          machineState: null,
        )).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Devices'),
        SizedBox(height: DesignSpacing.md),
        DeviceList(
          devices: cardData,
          expandedDeviceId: expandedDeviceId,
          onToggle: onToggle,
          onViewDetail: onViewDetail,
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border.all(color: DesignColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
    );
  }
}
