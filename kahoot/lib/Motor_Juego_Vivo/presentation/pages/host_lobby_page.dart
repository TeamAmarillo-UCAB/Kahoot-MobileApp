import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../widgets/dev_phase_controls.dart';
import '../bloc/game_state.dart';
import '../widgets/player_list_widget.dart';

class HostLobbyPage extends StatelessWidget {
  const HostLobbyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkBackground = const Color(0xFF222222);

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
        backgroundColor: darkBackground,
        appBar: AppBar(
          backgroundColor: darkBackground,
          title: const Text('Host - Lobby', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              context.read<GameBloc>().add(GameEventDisconnect());
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ),
        body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                if (state.isLoading) const LinearProgressIndicator(color: Colors.red),
                Expanded(child: PlayerListWidget(players: state.gameState.players)),
                const DevPhaseControls(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700, // Botón de host en verde
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: state.isLoading ? null : () => context.read<GameBloc>().add(GameEventHostStartGame()),
                    child: state.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Iniciar juego', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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