import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../notifications/data/notifications_repository.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';



/// Botón de notificaciones con badge animado y modal bottom sheet.
class DashboardNotificationButton extends StatefulWidget {
  const DashboardNotificationButton({
    super.key,
    required this.notifications,
    required this.onMarkAsRead,
    this.onSensorTap,
  });

  final List<NotificationItem> notifications;
  final Future<void> Function(List<String> ids) onMarkAsRead;
  final void Function(String sensorId)? onSensorTap;

  @override
  State<DashboardNotificationButton> createState() =>
      _DashboardNotificationButtonState();
}

class _DashboardNotificationButtonState
    extends State<DashboardNotificationButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellCtrl;
  late final Animation<double> _bellPulse;
  Timer? _bellStopTimer;
  int _lastBellCount = 0;
  int _lastStableBellCount = 0;

  @override
  void initState() {
    super.initState();
    _bellCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _bellPulse = CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _bellStopTimer?.cancel();
    _bellCtrl.stop();
    _bellCtrl.dispose();
    super.dispose();
  }

  void _startBellAnimation() {
    _bellStopTimer?.cancel();
    _bellCtrl.repeat(reverse: true);
    _bellStopTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) _stopBellAnimation();
    });
  }

  void _stopBellAnimation() {
    _bellStopTimer?.cancel();
    if (_bellCtrl.isAnimating) {
      _bellCtrl.stop();
    }
    _bellCtrl.value = 0;
  }

  Future<void> _handleMarkAsRead() async {
    if (widget.notifications.isEmpty) return;
    final ids = widget.notifications.map((n) => n.id).toList();
    await widget.onMarkAsRead(ids);
  }

  @override
  Widget build(BuildContext context) {
    final badgeCount = widget.notifications.length;
    final hasPreviousData = badgeCount > 0 || _lastStableBellCount > 0;
    final isTransient = badgeCount != _lastStableBellCount && hasPreviousData;
    final stableBadgeCount = isTransient ? _lastStableBellCount : badgeCount;
    if (!isTransient) {
      _lastStableBellCount = stableBadgeCount;
    }

    if (stableBadgeCount > _lastBellCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startBellAnimation();
      });
    }
    _lastBellCount = stableBadgeCount;

    return AnimatedBuilder(
      animation: _bellPulse,
      builder: (context, _) {
        final t = _bellPulse.value;
        final scale = 1.0 + (0.10 * t);
        final rot = 0.06 * math.sin(t * math.pi * 2);
        final glow = 0.20 * t;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: DesignColors.red.withValues(alpha: glow * 0.12),
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: rot,
                child: Transform.scale(
                  scale: scale,
                  child: IconButton(
                    onPressed: () async {
                      _stopBellAnimation();
                      await _handleMarkAsRead();
                      if (!mounted) return;
                      await showModalBottomSheet<void>(
                        context: this.context,
                        backgroundColor: DesignColors.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        builder: (_) => _NotificationsSheet(
                          notifications: widget.notifications,
                          onSensorTap: widget.onSensorTap,
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_none),
                    tooltip: 'Notificaciones',
                  ),
                ),
              ),
            ),
            if (stableBadgeCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: IgnorePointer(
                  ignoring: true,
                  child: Transform.scale(
                    scale: 1.0 + (0.08 * t),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: DesignColors.red,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({
    required this.notifications,
    this.onSensorTap,
  });

  final List<NotificationItem> notifications;
  final void Function(String sensorId)? onSensorTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_none, color: DesignColors.textPrimary),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    'Notificaciones (por sensor)',
                    style: DesignTextStyles.screenTitle,
                  ),
                ),
                Text(
                  notifications.length.toString(),
                  style: TextStyle(
                    color: DesignColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.md),
            if (notifications.isEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                child: Text(
                  'Sin eventos activos.',
                  style: DesignTextStyles.bodyText,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final sev = n.severity.toLowerCase();
                    final source = n.source.toLowerCase();

                    late final Color color;
                    late final IconData icon;
                    if (sev.contains('critical') || sev.contains('alert')) {
                      color = DesignColors.red;
                      icon = Icons.error;
                    } else if (source == 'ml_event') {
                      color = DesignColors.cyan;
                      icon = Icons.psychology;
                    } else {
                      color = DesignColors.amber;
                      icon = Icons.warning_amber;
                    }

                    final ts = date_utils.formatDateTimeShared(
                        n.createdAt.toIso8601String());
                    final sensorName =
                        (n.sensorName ?? '').trim().isEmpty ? 'Sensor' : n.sensorName!.trim();
                    final deviceName = (n.deviceName ?? '').trim();

                    return Card(
                      child: ListTile(
                        leading: Icon(icon, color: color, size: 20),
                        title: Text(
                          sensorName,
                          style: DesignTextStyles.bodyText,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${deviceName.isEmpty ? '-' : deviceName}\n${n.title} · $ts',
                          style: DesignTextStyles.bodyText,
                        ),
                        trailing:
                            Icon(Icons.chevron_right, color: DesignColors.textSecondary),
                        onTap: () {
                          final sensorId = (n.sensorId ?? '').trim();
                          Navigator.of(context).pop();
                          if (sensorId.isNotEmpty) {
                            onSensorTap?.call(sensorId);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
