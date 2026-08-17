import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.init();

  runApp(const NewsFlowApp());
}

class NewsFlowApp extends StatelessWidget {
  const NewsFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flews',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}