import 'package:flutter/material.dart';

import '../../../../core/auth/auth_storage.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../../../core/theme/design_text_styles.dart';
import '../../../crm/presentation/pages/crm_home_page.dart';
import '../../data/auth_repository.dart';

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
                  SizedBox(width: 12),
                  Expanded(child: Text(widget.initialErrorMessage!)),
                ],
              ),
              backgroundColor: DesignColors.amber,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignRadius.md),
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
      backgroundColor: DesignColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(DesignSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ZENIN',
                      style: DesignTextStyles.screenTitle
                          .copyWith(color: DesignColors.cyan, fontSize: 24)),
                  SizedBox(height: DesignSpacing.xs),
                  Text('IOT MONITORING SYSTEM',
                      style: DesignTextStyles.sectionTitle),
                  SizedBox(height: DesignSpacing.xxl),
                  Container(
                    decoration: BoxDecoration(
                      color: DesignColors.surface,
                      border: Border.all(color: DesignColors.border, width: 0.5),
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(DesignSpacing.xl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Usuario o email',
                                style: DesignTextStyles.bodyText),
                            SizedBox(height: DesignSpacing.xs),
                            _InputField(
                              controller: _usernameController,
                              hint: 'nombre@ejemplo.com',
                              icon: Icons.person_outline_rounded,
                              validator: (v) =>
                                  v?.trim().isEmpty ?? true ? 'Ingresa tu usuario' : null,
                            ),
                            SizedBox(height: DesignSpacing.lg),
                            Text('Contraseña', style: DesignTextStyles.bodyText),
                            SizedBox(height: DesignSpacing.xs),
                            _InputField(
                              controller: _passwordController,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: DesignColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Ingresa tu contraseña' : null,
                            ),
                            SizedBox(height: DesignSpacing.md),
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  activeColor: DesignColors.cyan,
                                  side: BorderSide(color: DesignColors.border),
                                ),
                                Text('Recordar sesión',
                                    style: DesignTextStyles.bodyText),
                              ],
                            ),
                            if (_errorMessage != null) ...[
                              SizedBox(height: DesignSpacing.md),
                              Container(
                                padding: EdgeInsets.all(DesignSpacing.md),
                                decoration: BoxDecoration(
                                  color: DesignColors.redDim,
                                  borderRadius:
                                      BorderRadius.circular(DesignRadius.md),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: DesignColors.red, size: 18),
                                    SizedBox(width: DesignSpacing.sm),
                                    Expanded(
                                      child: Text(_errorMessage!,
                                          style: DesignTextStyles.bodyText
                                              .copyWith(color: DesignColors.red)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: DesignSpacing.xl),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                child: _isLoading
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: DesignColors.background,
                                        ),
                                      )
                                    : const Text('CONECTAR'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: DesignSpacing.xl),
                  Text('v1.0.0 · ZENIN', style: DesignTextStyles.timestamp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: DesignTextStyles.bodyText.copyWith(color: DesignColors.textPrimary),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: DesignColors.textSecondary),
        suffixIcon: suffix,
        hintText: hint,
      ),
    );
  }
}