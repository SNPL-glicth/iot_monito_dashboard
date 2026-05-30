import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/sensor_bar.dart';
import '../../../../core/presentation/widgets/status_badge.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../../../core/theme/design_text_styles.dart';

class DeviceCard extends StatefulWidget {
  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.deviceId,
    required this.uptime,
    required this.sensorCount,
    required this.lastReadingTime,
    required this.sensors,
    required this.isExpanded,
    required this.onToggle,
    required this.onViewDetail,
    this.machineState,
  });

  final String deviceName;
  final String deviceId;
  final String uptime;
  final int sensorCount;
  final String lastReadingTime;
  final List<SensorInfo> sensors;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetail;
  final MachineState? machineState;

  Color get _accentColor {
    switch (machineState) {
      case MachineState.running:
        return DesignColors.cyan;
      case MachineState.starting:
        return DesignColors.cyan;
      case MachineState.degraded:
        return DesignColors.amber;
      case MachineState.fault:
        return DesignColors.red;
      case MachineState.idle:
      case null:
        return DesignColors.border;
    }
  }

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border.all(color: DesignColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            decoration: BoxDecoration(
              color: widget._accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DesignRadius.md),
                topRight: Radius.circular(DesignRadius.md),
              ),
            ),
          ),
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(DesignRadius.md),
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(widget.deviceName,
                            style: DesignTextStyles.cardTitle),
                      ),
                      StatusBadge(
                        label: (widget.machineState?.name ?? 'unknown')
                            .replaceAll('_', ' '),
                        state: widget.machineState ?? MachineState.idle,
                      ),
                      SizedBox(width: DesignSpacing.sm),
                      AnimatedRotation(
                        turns: widget.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down,
                            size: 20, color: DesignColors.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.xs),
                  Text(widget.deviceId, style: DesignTextStyles.deviceId),
                  SizedBox(height: DesignSpacing.xs),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget._accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: DesignSpacing.xs),
                      Text('$widget.sensorCount sensors',
                          style: DesignTextStyles.bodyText),
                      SizedBox(width: DesignSpacing.md),
                      Text('Last: ${widget.lastReadingTime}',
                          style: DesignTextStyles.timestamp),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: widget.isExpanded
                ? AnimatedOpacity(
                    opacity: widget.isExpanded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(height: 1, color: DesignColors.border),
                        Padding(
                          padding: EdgeInsets.all(DesignSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SENSORS',
                                  style: DesignTextStyles.sectionTitle),
                              SizedBox(height: DesignSpacing.sm),
                              ...widget.sensors.map((s) => SensorBar(
                                    label: s.name,
                                    value: s.value,
                                    min: s.min,
                                    max: s.max,
                                    unit: s.unit,
                                    state: s.state,
                                  )),
                              SizedBox(height: DesignSpacing.md),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: widget.onViewDetail,
                                  child: const Text('VIEW DETAIL →'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class SensorInfo {
  const SensorInfo({
    required this.name,
    required this.value,
    required this.min,
    required this.max,
    this.unit,
    this.state = MachineState.idle,
  });

  final String name;
  final double value;
  final double min;
  final double max;
  final String? unit;
  final MachineState state;
}
