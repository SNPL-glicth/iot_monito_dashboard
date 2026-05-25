import 'package:flutter/material.dart';

import '../../../../core/auth/auth_storage.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../crm/presentation/pages/crm_home_page.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../data/auth_repository.dart';
import '../widgets/login_form_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.initialErrorMessage,
  });

  /// Mensaje de error inicial mostrado cuando la sesión expiró
  /// o el bootstrap falló (ej. token inválido).
  final String? initialErrorMessage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late final AuthRepository _authRepository;
  late final AuthStorage _authStorage;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _authStorage = AuthStorage();

    // Mostrar mensaje de sesión expirada si viene del bootstrap
    if (widget.initialErrorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(widget.initialErrorMessage!)),
                ],
              ),
              backgroundColor: DashboardColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authRepository.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Persistir sesión si el usuario eligió "mantener sesión iniciada".
      if (_rememberMe) {
        await _authStorage.saveSession(
          token: result.token,
          role: result.role.name,
          username: _usernameController.text.trim(),
        );
        if (!mounted) return;
      }

      // FIX REALTIME: Conectar WebSocket para notificaciones en tiempo real
      RealtimeService().connect(authToken: result.token);

      // Nuevo flujo CRM: todos los roles entran al mismo shell con Drawer (offcanvas)
      // y el backend ya hace scoping por user_devices para operator/viewer.
      final Widget nextPage = CrmHomePage(role: result.role);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => nextPage),
      );
    } on AuthTimeoutException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Ocurrió un error inesperado. Intenta de nuevo más tarde.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo/Icono superior
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: DashboardColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: DashboardColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sensors_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Card principal de login
                Container(
                  decoration: ModernCardDecoration.elevated(),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenido',
                            style: DashboardTextStyles.sectionHeader,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ingresa tus credenciales para continuar',
                            style: DashboardTextStyles.sensorMeta,
                          ),
                          const SizedBox(height: 28),
                          
                          // Campo Usuario
                          LoginFormWidgets.buildInputLabel('Usuario o email'),
                          const SizedBox(height: 8),
                          LoginFormWidgets.buildModernTextField(
                            controller: _usernameController,
                            hintText: 'nombre@ejemplo.com',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa tu usuario';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Campo Contraseña
                          LoginFormWidgets.buildInputLabel('Contraseña'),
                          const SizedBox(height: 8),
                          LoginFormWidgets.buildModernTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? Icons.visibility_outlined 
                                    : Icons.visibility_off_outlined,
                                color: DashboardColors.white54,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Checkbox recordar
                          LoginFormWidgets.buildRememberMeCheckbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                          ),
                          
                          // Mensaje de error
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            LoginFormWidgets.buildErrorMessage(_errorMessage!),
                          ],
                          const SizedBox(height: 24),
                          
                          // Botón de login
                          LoginFormWidgets.buildLoginButton(
                            isLoading: _isLoading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sistema de Monitoreo IoT',
                  style: DashboardTextStyles.sensorMeta,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}