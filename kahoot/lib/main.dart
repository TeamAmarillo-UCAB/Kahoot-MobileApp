import 'package:flutter/material.dart';
import 'Creacion_edicion_quices/presentation/pages/home/home_page.dart';

const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://quizzy-backend-0wh2.onrender.com/api');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kahoot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// La página de creación real ahora está en create_kahoot_page.dart