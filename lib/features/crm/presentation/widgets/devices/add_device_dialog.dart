import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../../../devices/presentation/pages/devices_hub_page.dart';

/// Muestra diálogo informativo para agregar dispositivos desde CRM.
Future<void> showAddDeviceDialog({
  required BuildContext context,
  required UserRole role,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Agregar dispositivo'),
      content: const Text(
        'Próximamente: alta de dispositivos desde CRM.\n\n'
        'Por ahora puedes usar Dispositivos > Dispositivos y sensores.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        if (role == UserRole.admin)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DevicesHubPage(role: role),
                ),
              );
            },
            child: const Text('Ir a dispositivos'),
          ),
      ],
    ),
  );
}
