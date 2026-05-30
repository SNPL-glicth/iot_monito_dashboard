import 'package:flutter/material.dart';

import '../../../../../core/auth/auth_storage.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/realtime/realtime_service.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../../../core/theme/design_spacing.dart';

class DashboardAccessDenied extends StatelessWidget {
  const DashboardAccessDenied({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso restringido')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Este dashboard es solo para administradores.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  ApiClient.authToken = null;
                  await AuthStorage().clearSession();
                  RealtimeService().disconnect();
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Volver al login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
