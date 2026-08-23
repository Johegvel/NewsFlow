import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../service_locator.dart';
import '../auth/auth_screen.dart';
import '../home/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.97,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    final user = await ServiceLocator.authRepository.loadCurrentSession();
    await Future<void>.delayed(const Duration(milliseconds: 1900));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: user == null ? const AuthScreen() : const HomePage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
          child: Column(
            children: [
              const Spacer(flex: 3),
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 260,
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.amberAccent.withValues(alpha: 0.08),
                        blurRadius: 64,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/flews_logo.png',
                    width: 220,
                    height: 165,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.newspaper_rounded,
                      size: 100,
                      color: AppTheme.amberAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'MENOS RUIDO, MAYOR\nCALIDAD',
                textAlign: TextAlign.center,
                style: AppTheme.editorial(fontSize: 32, height: 1.12),
              ),
              const SizedBox(height: 12),
              const Text(
                'INFORMATIVA',
                style: TextStyle(
                  color: AppTheme.amberAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              const Spacer(flex: 3),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: AppTheme.amberAccent,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cargando la síntesis diaria...',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
