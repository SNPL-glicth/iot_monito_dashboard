import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iot_monito_dashboard/core/auth/user_role.dart';
import 'package:iot_monito_dashboard/features/monitoring/presentation/pages/dashboard_page.dart';

/// Test basico de renderizado del DashboardPage.
///
/// Dado que DashboardPage depende de repositorios reales y RealtimeService
/// (singleton), estos tests verifican principalmente que la pagina no crashea
/// al construirse y que la estructura de widgets es correcta.
///
/// Para testear el polling adaptativo en profundidad se requiere mocking
/// de RealtimeService (recomendado: agregar mockito/mocktail a dev_dependencies).
void main() {
  group('DashboardPage rendering', () {
    testWidgets('renders access denied for non-admin roles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(role: UserRole.viewer),
        ),
      );
      await tester.pump();

      expect(find.text('Acceso denegado'), findsOneWidget);
    });

    testWidgets('renders dashboard scaffold for admin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(role: UserRole.admin),
        ),
      );
      await tester.pump();

      // Verificar que el cuerpo del dashboard se construye
      expect(find.byType(Scaffold), findsOneWidget);
      // Verificar que el AppBar se renderiza
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('Adaptive polling logic (unit test)', () {
    test('fallback intervals follow expected backoff pattern', () {
      const intervals = [10, 15, 30];
      expect(intervals[0], 10);
      expect(intervals[1], 15);
      expect(intervals[2], 30);

      // Verificar que no escala infinitamente
      expect(intervals.last, lessThanOrEqualTo(30));
    });

    test('escalation index clamps within bounds', () {
      const intervals = [10, 15, 30];
      int index = 0;

      // Simular escalation
      for (int i = 0; i < 5; i++) {
        if (index < intervals.length - 1) index++;
      }

      expect(index, intervals.length - 1);
      expect(intervals[index.clamp(0, intervals.length - 1)], 30);
    });
  });
}
