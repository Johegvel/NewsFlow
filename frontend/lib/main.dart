import 'package:flutter/material.dart';

import 'screens/auth_page.dart';
import 'screens/home_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const NewsFlowApp());
}

class NewsFlowApp extends StatefulWidget {
  const NewsFlowApp({super.key});

  @override
  State<NewsFlowApp> createState() => _NewsFlowAppState();
}

class _NewsFlowAppState extends State<NewsFlowApp> {
  bool loading = true;
  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final sessionExists = await AuthService.isAuthenticated();

    setState(() {
      authenticated = sessionExists;
      loading = false;
    });
  }

  void showHome() {
    setState(() {
      authenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : authenticated
          ? const HomePage()
          : AuthPage(onAuthenticated: showHome),
    );
  }
}
