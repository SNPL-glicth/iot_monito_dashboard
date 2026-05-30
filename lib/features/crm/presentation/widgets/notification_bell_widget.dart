import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/notifications/notification_state_service.dart';
import '../../../devices/presentation/pages/sensor_details_route_page.dart';
import 'notifications/notifications_dialog.dart';
import 'notifications/notification_bell_icon.dart';
import '../../../../core/theme/design_colors.dart';

/// Widget de campana de notificaciones - REFACTOR ESTRUCTURAL.
/// 
/// ARQUITECTURA REACTIVA PURA:
/// - NUNCA lee getters sync del servicio en build()
/// - USA StreamBuilder para escuchar cambios
/// - Todas las operaciones son async y esperan completar
/// 
/// FLUJOS DETERMINISTAS:
/// - init: fetch() → stream emite → UI actualiza
/// - open: await fetch() → mostrar dialog
/// - markAsRead: await markAsRead() → stream emite → UI actualiza
/// - close: await fetch() → stream emite → UI actualiza
class NotificationBellWidget extends StatefulWidget {
  const NotificationBellWidget({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  State<NotificationBellWidget> createState() => _NotificationBellWidgetState();
}

class _NotificationBellWidgetState extends State<NotificationBellWidget>
    with SingleTickerProviderStateMixin {
  final NotificationStateService _service = NotificationStateService();
  
  // FIX FREEZE: Animación nullable para inicialización diferida
  AnimationController? _bellCtrl;
  Animation<double>? _bellPulse;
  Timer? _bellStopTimer;
  
  int _lastUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _bellCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 650),
      );
      _bellPulse = CurvedAnimation(parent: _bellCtrl!, curve: Curves.easeInOut);
      if (mounted) setState(() {});
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      _service.startPolling();
    });
  }

  @override
  void dispose() {
    _bellStopTimer?.cancel();
    _service.stopPolling();
    _bellCtrl?.stop();
    _bellCtrl?.dispose();
    super.dispose();
  }

  void _startBellAnimation() {
    if (_bellCtrl == null) return; // FIX: Animación aún no inicializada
    _bellStopTimer?.cancel();
    _bellCtrl!.repeat(reverse: true);
    _bellStopTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _stopBellAnimation();
    });
  }

  void _stopBellAnimation() {
    if (_bellCtrl == null) return; // FIX: Animación aún no inicializada
    _bellStopTimer?.cancel();
    if (_bellCtrl!.isAnimating) {
      _bellCtrl!.stop();
    }
    _bellCtrl!.value = 0;
  }

  /// Abre el diálogo de notificaciones.
  /// IMPORTANTE: Espera el fetch antes de mostrar.
  Future<void> _showNotificationsPopover() async {
    _stopBellAnimation();
    await _service.fetchNotifications(force: true);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => NotificationsDialog(
        service: _service,
        onNotificationTap: (notification) async {
          Navigator.of(ctx).pop();
          await _handleNotificationTap(notification);
        },
      ),
    );
    
    if (!mounted) return;
    await _service.fetchNotifications(force: true);
  }

  /// Maneja tap en notificación.
  /// IMPORTANTE: Espera markAsRead antes de navegar.
  Future<void> _handleNotificationTap(AppNotification notification) async {
    await _service.markAsRead(notification.id);
    if (!mounted) return;
    if (notification.sensorId != null) {
      Navigator.of(context).pushNamed(
        '/sensor-details',
        arguments: SensorDetailsArgs(
          sensorId: notification.sensorId!,
          highlightTimestamp: notification.createdAt,
        ),
      );
    }
  }

  /// Maneja cambios en el estado para animación
  void _onStateChanged(NotificationState state) {
    final newCount = state.unreadCount;
    if (newCount > _lastUnreadCount && _lastUnreadCount > 0) {
      _startBellAnimation();
    }
    _lastUnreadCount = newCount;
  }

  @override
  Widget build(BuildContext context) {
    // USA StreamBuilder - NUNCA lee getters sync del servicio
    return StreamBuilder<NotificationState>(
      stream: _service.stateStream,
      initialData: _service.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? NotificationState.empty;
        
        // Detectar cambios para animación
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onStateChanged(state);
        });
        
        final unreadCount = state.unreadCount;
        final hasAlerts = state.unreadAlertCount > 0;
        final badgeColor = hasAlerts ? DesignColors.red : Colors.purpleAccent;
        
        return NotificationBellIcon(
          animation: _bellPulse,
          unreadCount: unreadCount,
          badgeColor: badgeColor,
          onTap: _showNotificationsPopover,
        );
      },
    );
  }
}

