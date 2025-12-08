import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';

class EnterPinPage extends StatefulWidget {
  const EnterPinPage({Key? key}) : super(key: key);

  @override
  State<EnterPinPage> createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Usamos los colores del tema de Kahoot! (Amber Oscuro para AppBar)
    final kahootYellow = const Color(0xFFFFD54F);
    final darkBackground = const Color(0xFF222222);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: kahootYellow,
        title: const Text('Entrar con PIN', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TextField estilizado para fondo oscuro
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'PIN de la partida',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kahootYellow, width: 2)),
              ),
            ),
            const SizedBox(height: 24),
            // Botón principal con el acento amarillo/naranja
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kahootYellow,
                foregroundColor: Colors.brown.shade800,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final pin = _pinController.text.trim();
                if (pin.isEmpty) return;

                context.read<GameBloc>().add(GameEventDisconnect());

                Navigator.pushNamed(
                  context,
                  '/enter_nickname',
                  arguments: pin,
                );
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}