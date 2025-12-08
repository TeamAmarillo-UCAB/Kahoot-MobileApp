import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';

class EnterNicknamePage extends StatefulWidget {
  const EnterNicknamePage({Key? key}) : super(key: key);

  @override
  State<EnterNicknamePage> createState() => _EnterNicknamePageState();
}

class _EnterNicknamePageState extends State<EnterNicknamePage> {
  final _nickController = TextEditingController();
  String _role = 'PLAYER';

  @override
  Widget build(BuildContext context) {
    final pin = ModalRoute.of(context)!.settings.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a la partida')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('PIN: $pin', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _nickController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),

              // Role selector
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Jugador'),
                      value: 'PLAYER',
                      groupValue: _role,
                      onChanged: (v) => setState(() => _role = v ?? 'PLAYER'),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Anfitrión'),
                      value: 'HOST',
                      groupValue: _role,
                      onChanged: (v) => setState(() => _role = v ?? 'PLAYER'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      final nick = _nickController.text.trim();
                      if (nick.isEmpty) return;

                      final bloc = context.read<GameBloc>();
                      bloc.add(GameEventJoin(
                        pin: pin,
                        role: _role,
                        playerId: DateTime.now().millisecondsSinceEpoch.toString(),
                        username: nick,
                        nickname: nick,
                      ));

                      // Navigate according to role — lobby pages will react to server updates
                      if (_role == 'HOST') {
                        Navigator.pushReplacementNamed(context, '/host_lobby');
                      } else {
                        Navigator.pushReplacementNamed(context, '/lobby');
                      }
                    },
                    child: Text(_role == 'HOST' ? 'Crear sesión (Host)' : 'Unirse como jugador'),
                  ),
                ),
              ])
            ]),
          ),
        ),
      ),
    );
  }
}