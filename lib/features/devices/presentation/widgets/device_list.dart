import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/status_badge.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../../../core/theme/design_text_styles.dart';
import 'device_card.dart';

class DeviceList extends StatelessWidget {
  const DeviceList({
    super.key,
    required this.devices,
    this.expandedDeviceId,
    required this.onToggle,
    required this.onViewDetail,
    this.isLoading = false,
  });

  final List<DeviceCardData> devices;
  final String? expandedDeviceId;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onViewDetail;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: List.generate(3, (_) => _SkeletonCard()),
      );
    }

    if (devices.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.xl),
          child: Column(
            children: [
              Icon(Icons.devices_other,
                  size: 48, color: DesignColors.textDim),
              SizedBox(height: DesignSpacing.md),
              Text('No devices found', style: DesignTextStyles.bodyText),
            ],
          ),
        ),
      );
    }

    return Column(
      children: devices.map((d) {
        return DeviceCard(
          deviceName: d.deviceName,
          deviceId: d.deviceId,
          uptime: d.uptime,
          sensorCount: d.sensorCount,
          lastReadingTime: d.lastReadingTime,
          sensors: d.sensors,
          isExpanded: d.deviceId == expandedDeviceId,
          onToggle: () => onToggle(d.deviceId),
          onViewDetail: () => onViewDetail(d.deviceId),
          machineState: d.machineState,
        );
      }).toList(),
    );
  }
}

class DeviceCardData {
  const DeviceCardData({
    required this.deviceId,
    required this.deviceName,
    required this.uptime,
    required this.sensorCount,
    required this.lastReadingTime,
    required this.sensors,
    this.machineState,
  });

  final String deviceId;
  final String deviceName;
  final String uptime;
  final int sensorCount;
  final String lastReadingTime;
  final List<SensorInfo> sensors;
  final MachineState? machineState;
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border.all(color: DesignColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonLine(width: 120, height: 14),
            SizedBox(height: DesignSpacing.sm),
            _SkeletonLine(width: 80, height: 10),
            SizedBox(height: DesignSpacing.sm),
            _SkeletonLine(width: 200, height: 10),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DesignColors.surface2,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
    );
  }
}
