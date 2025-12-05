import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_state.dart';

class HostPodiumPage extends StatelessWidget {
  const HostPodiumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host - Podio')),
      body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
        final board = state.gameState.scoreboard;
        return ListView(children: board.map((e) => ListTile(
              title: Text(e.nickname),
              subtitle: Text('Puntos: ${e.totalPoints}'),
              trailing: Text('#${e.position}'),
            )).toList());
      }),
    );
  }
}
