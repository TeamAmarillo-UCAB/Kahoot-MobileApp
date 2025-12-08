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
    final darkBackground = const Color(0xFF222222);
    final kahootYellow = const Color(0xFFFFD54F);

    return BlocListener<GameBloc, GameUiState>(
      listener: (context, state) {
        // 🚀 CORRECCIÓN CLAVE: Diferir la navegación 🚀
        // Esto permite que el estado del widget se estabilice antes de cambiar de ruta.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.isQuestion) {
            // Usar rootNavigator: true es a menudo más seguro.
            Navigator.of(context, rootNavigator: true).pushReplacementNamed('/player_question');
          } else if (state.isResults) {
            Navigator.of(context, rootNavigator: true).pushReplacementNamed('/player_results');
          } else if (state.isEnd) {
            Navigator.of(context, rootNavigator: true).pushReplacementNamed('/podium');
          }
        });
      },
      child: Scaffold(
        backgroundColor: darkBackground,
        appBar: AppBar(
          backgroundColor: darkBackground,
          title: const Text('Lobby', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              context.read<GameBloc>().add(GameEventDisconnect());
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ),
        body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
          final isHost = state.gameState.players.any((p) => p.isHost);
          return Column(
            children: [
              if (state.isLoading) const LinearProgressIndicator(color: Colors.red),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.gameState.quizTitle ?? 'Quiz', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: kahootYellow, fontSize: 24)),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share, color: Colors.brown),
                      label: const Text('Invitar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kahootYellow,
                        foregroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(child: PlayerListWidget(players: state.gameState.players)),
              const DevPhaseControls(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isHost ? Colors.green.shade700 : Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (isHost) {
                              context.read<GameBloc>().add(GameEventHostStartGame());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esperando a que el host inicie el juego')));
                            }
                          },
                    child: state.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isHost ? 'Iniciar juego' : 'Esperando al host', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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