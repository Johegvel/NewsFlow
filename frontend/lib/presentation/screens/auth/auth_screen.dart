import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../service_locator.dart';
import '../home/home_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  static const bool _demoLoginEnabled = bool.fromEnvironment(
    'ENABLE_DEMO_LOGIN',
    defaultValue: false,
  );

  late final TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging && mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _fillDemo(String email) {
    setState(() {
      _loginEmailController.text = email;
      _loginPasswordController.text = 'FlewsDemo2026!';
    });
  }

  void _onAuthSuccess(UserEntity user, String message) {
    if (!mounted) return;
    FlewsNotificationHelper.show(
      context: context,
      title: '¡Bienvenido a Flews!',
      message: message,
      actionIcon: Icons.check_circle_rounded,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showRequired('Ingresa tu correo y contraseña.');
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await ServiceLocator.authRepository.login(email, password);
      _onAuthSuccess(user, 'Sesión iniciada como ${user.name}.');
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'No pudimos iniciar sesión',
          message: '$error'.replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleRegister() async {
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showRequired('Completa nombre, correo y contraseña.');
      return;
    }
    if (password.length < 6) {
      _showRequired('La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await ServiceLocator.authRepository.register(
        name,
        email,
        password,
      );
      _onAuthSuccess(user, 'Tu cuenta fue creada correctamente.');
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'No pudimos crear tu cuenta',
          message: '$error'.replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showRequired(String message) {
    FlewsNotificationHelper.show(
      context: context,
      title: 'Revisa los datos',
      message: message,
      actionIcon: Icons.warning_amber_rounded,
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
            suffixIcon: toggleObscure == null
                ? null
                : IconButton(
                    onPressed: toggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _loginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(
          controller: _loginEmailController,
          label: 'Correo electrónico',
          hint: 'tu@correo.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _field(
          controller: _loginPasswordController,
          label: 'Contraseña',
          hint: 'Ingresa tu contraseña',
          icon: Icons.lock_outline_rounded,
          obscure: _obscureLoginPassword,
          toggleObscure: () =>
              setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 22),
        FilledButton(
          key: const ValueKey('login-button'),
          onPressed: _loading ? null : _handleLogin,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.darkBackground,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Iniciar Sesión'),
        ),
      ],
    );
  }

  Widget _registerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(
          controller: _registerNameController,
          label: 'Nombre completo',
          hint: 'Cómo quieres aparecer',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 13),
        _field(
          controller: _registerEmailController,
          label: 'Correo electrónico',
          hint: 'tu@correo.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 13),
        _field(
          controller: _registerPasswordController,
          label: 'Contraseña',
          hint: 'Mínimo 6 caracteres',
          icon: Icons.lock_outline_rounded,
          obscure: _obscureRegisterPassword,
          toggleObscure: () => setState(
            () => _obscureRegisterPassword = !_obscureRegisterPassword,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleRegister(),
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const ValueKey('register-button'),
          onPressed: _loading ? null : _handleRegister,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.darkBackground,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Crear Cuenta'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final registering = _tabController.index == 1;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          child: ResponsiveContainer(
            maxWidth: 430,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/flews_logo.png',
                    width: 140,
                    height: 105,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.newspaper_rounded,
                      size: 72,
                      color: AppTheme.amberAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  registering ? 'Únete a la comunidad' : 'Bienvenido de nuevo',
                  textAlign: TextAlign.center,
                  style: AppTheme.editorial(fontSize: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  registering
                      ? 'Crea tu perfil para guardar noticias y publicar análisis.'
                      : 'Tu síntesis diaria y la Tribuna te esperan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.amberAccent,
                  indicatorWeight: 2,
                  dividerColor: AppTheme.borderColor,
                  labelColor: AppTheme.amberAccent,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Iniciar Sesión'),
                    Tab(text: 'Crear Cuenta'),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor, width: 1.5),
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    child: registering ? _registerForm() : _loginForm(),
                  ),
                ),
                if (!registering && _demoLoginEnabled) ...[
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ACCESO DE PRUEBA',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _fillDemo('demo1@flews.app'),
                          child: const Text('Demo 1'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _fillDemo('demo2@flews.app'),
                          child: const Text('Demo 2'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
