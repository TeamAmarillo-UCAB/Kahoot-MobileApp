import 'package:flutter/material.dart';
import 'Creacion_edicion_quices/presentation/pages/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kahoot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: HomePage(
        onCreate: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DummyCreatePage()),
          );
        },
      ),
    );
  }
}

class DummyCreatePage extends StatelessWidget {
  const DummyCreatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Kahoot')),
      body: const Center(child: Text('Pantalla de creación de Kahoot (dummy)')),
    );
  }
}