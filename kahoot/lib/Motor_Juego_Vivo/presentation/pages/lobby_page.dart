import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../widgets/dev_phase_controls.dart';
import '../bloc/game_state.dart';
import '../widgets/player_list_widget.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameUiState>(
      listener: (context, state) {
        if (state.isQuestion) {
          Navigator.of(context).pushReplacementNamed('/player_question');
        } else if (state.isResults) {
          Navigator.of(context).pushReplacementNamed('/player_results');
        } else if (state.isEnd) {
          Navigator.of(context).pushReplacementNamed('/podium');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Lobby')),
        body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
          final isHost = state.gameState.players.any((p) => p.isHost);
          return Column(
            children: [
              if (state.isLoading) const LinearProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.gameState.quizTitle ?? 'Quiz', style: Theme.of(context).textTheme.titleLarge),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      label: const Text('Invitar'),
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    )
                  ],
                ),
              ),
              Expanded(child: PlayerListWidget(players: state.gameState.players)),
              const SizedBox(height: 8),
              const DevPhaseControls(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (isHost) {
                              context.read<GameBloc>().add(GameEventHostStartGame());
                            } else {
                              // show waiting snackbar
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esperando a que el host inicie el juego')));
                            }
                          },
                    child: state.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isHost ? 'Iniciar juego' : 'Esperando al host'),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
