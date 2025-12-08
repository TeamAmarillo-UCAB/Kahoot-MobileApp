import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_state.dart';
import '../bloc/game_event.dart'; // Asegúrate de que GameEvent esté importado

class PodiumPage extends StatelessWidget {
  const PodiumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkBackground = const Color(0xFF222222);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        title: const Text('Podio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            context.read<GameBloc>().add(GameEventDisconnect());
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),
      body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
        final board = state.gameState.scoreboard;
        return Column(
            children: [
                const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('¡Felicidades al ganador!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber)),
                ),
                Expanded(
                    child: ListView(
                        children: board.map((e) => ListTile(
                                tileColor: Colors.grey.shade900,
                                leading: CircleAvatar(
                                    backgroundColor: e.position == 1 ? Colors.amber.shade400 : e.position == 2 ? Colors.grey : Colors.brown,
                                    child: Text('#${e.position}', style: TextStyle(color: e.position == 1 ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(e.nickname, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text('Puntos: ${e.totalPoints}', style: const TextStyle(color: Colors.white70)),
                            )
                        ).toList(),
                    ),
                ),
            ],
        );
      }),
    );
  }
}