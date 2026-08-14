import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthPage({super.key, required this.onAuthenticated});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService authService = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmationController = TextEditingController();

  bool isRegistering = false;
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmationController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage('Completa el correo y la contraseña');
      return;
    }

    if (isRegistering &&
        (nameController.text.trim().isEmpty ||
            confirmationController.text.isEmpty)) {
      showMessage('Completa todos los campos');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      if (isRegistering) {
        await authService.register(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          passwordConfirmation: confirmationController.text,
        );
      } else {
        await authService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      }

      widget.onAuthenticated();
    } catch (error) {
      showMessage('Error: $error');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NewsFlow',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  if (isRegistering)
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  if (isRegistering) const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (isRegistering) const SizedBox(height: 16),
                  if (isRegistering)
                    TextField(
                      controller: confirmationController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: loading ? null : submit,
                      child: Text(
                        loading
                            ? 'Procesando...'
                            : isRegistering
                            ? 'Registrarse'
                            : 'Iniciar sesión',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            setState(() {
                              isRegistering = !isRegistering;
                            });
                          },
                    child: Text(
                      isRegistering
                          ? 'Ya tengo una cuenta'
                          : 'Crear una cuenta',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
