import 'package:flutter/material.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const NewsFlowApp());
}

class NewsFlowApp extends StatelessWidget {
  const NewsFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}