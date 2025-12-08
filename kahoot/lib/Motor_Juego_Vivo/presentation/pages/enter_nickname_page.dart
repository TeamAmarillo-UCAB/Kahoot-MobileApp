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
    final kahootYellow = const Color(0xFFFFD54F);
    final kahootOrange = const Color(0xFFFFB300);
    final darkBackground = const Color(0xFF222222);
    final cardColor = Colors.grey.shade900;

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: kahootYellow,
        title: const Text('Unirse a la partida', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Card(
          color: cardColor, // Tarjeta oscura
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('PIN: $pin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kahootOrange)), // PIN en naranja
              const SizedBox(height: 24),
              TextField(
                controller: _nickController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.person, color: kahootYellow),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kahootYellow, width: 2)),
                ),
              ),
              const SizedBox(height: 16),

              // Role selector
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      activeColor: kahootYellow,
                      title: const Text('Jugador', style: TextStyle(color: Colors.white)),
                      value: 'PLAYER',
                      groupValue: _role,
                      onChanged: (v) => setState(() => _role = v ?? 'PLAYER'),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      activeColor: kahootYellow,
                      title: const Text('Anfitrión', style: TextStyle(color: Colors.white)),
                      value: 'HOST',
                      groupValue: _role,
                      onChanged: (v) => setState(() => _role = v ?? 'PLAYER'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _role == 'HOST' ? kahootOrange : kahootYellow, // Distinguimos el color para Host
                      foregroundColor: Colors.brown.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final nick = _nickController.text.trim();
                      if (nick.isEmpty) return;

                      final bloc = context.read<GameBloc>();
                      bloc.add(GameEventJoin(
                        pin: pin,
                        role: _role,
                        // Usamos un ID de jugador más estable para Fake Datasource
                        playerId: 'dev_player_${nick.replaceAll(' ', '_')}', 
                        username: nick,
                        nickname: nick,
                      ));

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