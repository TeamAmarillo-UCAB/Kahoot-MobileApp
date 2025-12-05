import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/player_list_widget.dart';

class HostLobbyPage extends StatelessWidget {
  const HostLobbyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameUiState>(
      listener: (context, state) {
        if (state.isQuestion) {
          Navigator.of(context).pushReplacementNamed('/host_question');
        } else if (state.isResults) {
          Navigator.of(context).pushReplacementNamed('/host_results');
        } else if (state.isEnd) {
          Navigator.of(context).pushReplacementNamed('/host_podium');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Host - Lobby')),
        body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                if (state.isLoading) const LinearProgressIndicator(),
                Expanded(child: PlayerListWidget(players: state.gameState.players)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: state.isLoading ? null : () => context.read<GameBloc>().add(GameEventHostStartGame()),
                    child: state.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Iniciar juego'),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
