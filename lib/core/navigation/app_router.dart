import 'package:flutter/material.dart';

import '../../core/auth/user_role.dart';
import '../../features/devices/presentation/pages/add_device_screen.dart';
import '../../features/devices/presentation/pages/device_detail_page.dart';
import '../../features/devices/presentation/pages/sensor_details_route_page.dart';
import 'app_transitions.dart';

class AppRouter {
  static Route? onGenerate(RouteSettings settings) {
    final name = settings.name ?? '';

    if (name == '/devices/create' || name == '/devices/add') {
      return FadePageRoute(
        builder: (_) => const AddDeviceScreen(),
        settings: settings,
      );
    }

    if (name.startsWith('/device/')) {
      final deviceId = name.substring('/device/'.length);
      if (deviceId.trim().isNotEmpty) {
        return SlidePageRoute(
          builder: (_) => DeviceDetailPage(
            role: UserRole.admin,
            deviceId: deviceId,
            deviceName: 'Dispositivo',
          ),
          settings: settings,
        );
      }
    }

    if (name.startsWith('/sensor/')) {
      final sensorId = name.substring('/sensor/'.length);
      if (sensorId.trim().isNotEmpty) {
        return SlidePageRoute(
          builder: (_) => SensorDetailsRoutePage(
            args: SensorDetailsArgs(sensorId: sensorId),
          ),
          settings: settings,
        );
      }
    }

    if (name == '/sensor-details') {
      final args = settings.arguments;
      if (args is SensorDetailsArgs) {
        return SlidePageRoute(
          builder: (_) => SensorDetailsRoutePage(args: args),
          settings: settings,
        );
      }
      return SlidePageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Ruta /sensor-details requiere SensorDetailsArgs'),
          ),
        ),
        settings: settings,
      );
    }

    return null;
  }
}
