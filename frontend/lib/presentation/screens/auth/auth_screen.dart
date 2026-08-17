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
  late TabController _tabController;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();

  bool _loading = false;
  List<UserEntity> _demoUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDemoUsers();
  }

  Future<void> _loadDemoUsers() async {
    try {
      final users = await ServiceLocator.authRepository.fetchAvailableUsers();
      if (mounted) {
        setState(() {
          _demoUsers = users;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    super.dispose();
  }

  void _onAuthSuccess(UserEntity user, String welcomeMessage) {
    if (!mounted) return;
    FlewsNotificationHelper.show(
      context: context,
      title: '¡Bienvenido a Flews!',
      message: welcomeMessage,
      actionIcon: Icons.check_circle_rounded,
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _handleLogin([String? presetEmail]) async {
    final email = presetEmail ?? _loginEmailController.text.trim();
    if (email.isEmpty) {
      FlewsNotificationHelper.show(
        context: context,
        title: 'Campo requerido',
        message: 'Por favor ingresa tu correo electrónico.',
        actionIcon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await ServiceLocator.authRepository.login(email);
      _onAuthSuccess(user, 'Sesión iniciada como ${user.name}');
    } catch (e) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Error de inicio de sesión',
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleRegister() async {
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      FlewsNotificationHelper.show(
        context: context,
        title: 'Campos requeridos',
        message: 'Completa tu nombre y correo electrónico.',
        actionIcon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await ServiceLocator.authRepository.register(name, email);
      _onAuthSuccess(user, 'Tu cuenta ${user.name} ha sido creada con éxito.');
    } catch (e) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Error al registrarte',
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ResponsiveContainer(
              maxWidth: 480,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Emblem
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.amberAccent.withValues(alpha: 0.2),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/flews_logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.newspaper_rounded,
                            size: 60,
                            color: AppTheme.amberAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Wordmark
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'Flew'),
                          TextSpan(
                            text: 's',
                            style: TextStyle(
                              color: AppTheme.amberAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Menos noticias irrelevantes • Mayor calidad',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Auth Card Container
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tabs Header
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              color: AppTheme.amberAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelColor: Colors.black,
                            unselectedLabelColor: AppTheme.textSecondary,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            tabs: const [
                              Tab(text: 'Iniciar Sesión'),
                              Tab(text: 'Registrarse'),
                            ],
                          ),
                        ),

                        // Form Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          child: SizedBox(
                            height: 240,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Tab 1: Login Form
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _loginEmailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Correo Electrónico',
                                        hintText: 'ej. usuario@flews.app',
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: AppTheme.amberAccent,
                                        ),
                                        filled: true,
                                        fillColor: AppTheme.darkBackground,
                                      ),
                                      onSubmitted: (_) => _handleLogin(),
                                    ),
                                    const SizedBox(height: 20),
                                    FilledButton(
                                      onPressed:
                                          _loading ? null : () => _handleLogin(),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppTheme.amberAccent,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.black,
                                              ),
                                            )
                                          : const Text(
                                              'Entrar a Flews',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),

                                // Tab 2: Register Form
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _registerNameController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Nombre Completo',
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
                                          color: AppTheme.amberAccent,
                                        ),
                                        filled: true,
                                        fillColor: AppTheme.darkBackground,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _registerEmailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Correo Electrónico',
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: AppTheme.amberAccent,
                                        ),
                                        filled: true,
                                        fillColor: AppTheme.darkBackground,
                                      ),
                                      onSubmitted: (_) => _handleRegister(),
                                    ),
                                    const SizedBox(height: 16),
                                    FilledButton(
                                      onPressed:
                                          _loading ? null : _handleRegister,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppTheme.amberAccent,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.black,
                                              ),
                                            )
                                          : const Text(
                                              'Crear Cuenta',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Demo quick access
                  if (_demoUsers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'O entra rápidamente con un usuario demo:',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _demoUsers.map((u) {
                        return ActionChip(
                          avatar: CircleAvatar(
                            backgroundColor: AppTheme.amberAccent,
                            child: Text(
                              u.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          label: Text(u.name),
                          backgroundColor: AppTheme.surfaceColor,
                          side: const BorderSide(color: AppTheme.borderColor),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          onPressed: () => _handleLogin(u.email),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
