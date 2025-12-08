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
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar con PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'PIN de la partida',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final pin = _pinController.text.trim();
                if (pin.isEmpty) return;

                // 🔥 IMPORTANTE:
                // Antes de entrar al flujo, limpiamos completamente el estado.
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