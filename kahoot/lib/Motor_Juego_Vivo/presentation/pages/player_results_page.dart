import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_state.dart';
import '../widgets/scoreboard_widget.dart';

class PlayerResultsPage extends StatelessWidget {
  const PlayerResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
        return Column(
          children: [
            if (state.gameState.correctAnswerId != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Respuesta correcta: ${state.gameState.correctAnswerId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            Expanded(child: ScoreboardWidget(entries: state.gameState.scoreboard)),
          ],
        );
      }),
    );
  }
}
