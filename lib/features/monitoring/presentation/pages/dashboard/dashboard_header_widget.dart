import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../devices/presentation/pages/sensor_details_route_page.dart';
import '../../../../notifications/data/notifications_repository.dart';
import '../../styles/dashboard_styles.dart';

/// Header widget with notification bell for dashboard
class DashboardHeaderWidget extends StatefulWidget {
  const DashboardHeaderWidget({
    super.key,
    required this.roleLabel,
    required this.notifications,
    required this.onNotificationsRead,
  });

  final String roleLabel;
  final List<NotificationItem> notifications;
  final VoidCallback onNotificationsRead;

  @override
  State<DashboardHeaderWidget> createState() => _DashboardHeaderWidgetState();
}

class _DashboardHeaderWidgetState extends State<DashboardHeaderWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellCtrl;
  late final Animation<double> _bellPulse;
  int _lastBellCount = 0;
  Timer? _bellStopTimer;

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
      if (!mounted) return;
      _stopBellAnimation();
    });
  }

  void _stopBellAnimation() {
    _bellStopTimer?.cancel();
    if (_bellCtrl.isAnimating) {
      _bellCtrl.stop();
    }
    _bellCtrl.value = 0;
  }

  String _formatDateTime(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeCount = widget.notifications.length;

    if (badgeCount > _lastBellCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startBellAnimation();
      });
    }
    _lastBellCount = badgeCount;

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
                color: Colors.redAccent.withValues(alpha: glow * 0.12),
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: rot,
                child: Transform.scale(
                  scale: scale,
                  child: IconButton(
                    onPressed: () async {
                      _stopBellAnimation();
                      widget.onNotificationsRead();

                      if (!mounted) return;
                      await showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: DashboardColors.cardBackground,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        builder: (context) => _NotificationsSheet(
                          notifications: widget.notifications,
                          formatDateTime: _formatDateTime,
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_none),
                    tooltip: 'Notificaciones',
                  ),
                ),
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: IgnorePointer(
                  ignoring: true,
                  child: Transform.scale(
                    scale: 1.0 + (0.08 * t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        widget.notifications.length > 99 ? '99+' : '${widget.notifications.length}',
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
    required this.formatDateTime,
  });

  final List<NotificationItem> notifications;
  final String Function(String?) formatDateTime;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_none, color: Colors.white70),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Notificaciones (por sensor)',
                    style: DashboardTextStyles.sectionHeader,
                  ),
                ),
                Text(
                  notifications.length.toString(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Sin eventos activos.',
                  style: DashboardTextStyles.sensorMeta,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final sev = (n.severity).toLowerCase();
                    final source = (n.source).toLowerCase();
                    
                    Color color;
                    IconData icon;
                    if (sev.contains('critical') || sev.contains('alert')) {
                      color = Colors.redAccent;
                      icon = Icons.error;
                    } else if (source == 'ml_event') {
                      color = Colors.lightBlueAccent;
                      icon = Icons.psychology;
                    } else {
                      color = Colors.orangeAccent;
                      icon = Icons.warning_amber;
                    }
                    final ts = formatDateTime(n.createdAt.toIso8601String());
                    final sensorName = (n.sensorName ?? '').trim().isEmpty ? 'Sensor' : n.sensorName!.trim();
                    final deviceName = (n.deviceName ?? '').trim();

                    return Card(
                      child: ListTile(
                        leading: Icon(icon, color: color, size: 20),
                        title: Text(
                          sensorName,
                          style: DashboardTextStyles.sensorTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${deviceName.isEmpty ? '-' : deviceName}\n${n.title} · $ts',
                          style: DashboardTextStyles.sensorMeta,
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () {
                          final sensorId = (n.sensorId ?? '').trim();
                          final nav = Navigator.of(context, rootNavigator: true);
                          Navigator.of(context).pop();
                          Future.microtask(() {
                            if (sensorId.isNotEmpty) {
                              nav.pushNamed(
                                '/sensor/$sensorId',
                                arguments: SensorDetailsArgs(sensorId: sensorId),
                              );
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 6),
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
