import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_state.dart';
import '../widgets/scoreboard_widget.dart';

class PlayerResultsPage extends StatelessWidget {
  const PlayerResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkBackground = const Color(0xFF222222);
    final cardColor = Colors.grey.shade900;
    final kahootYellow = const Color(0xFFFFD54F);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
          backgroundColor: darkBackground,
          title: const Text('Resultados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
        // Navegamos si la fase ha cambiado
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isResults) {
            if (state.isQuestion) Navigator.of(context).pushReplacementNamed('/player_question');
            if (state.isEnd) Navigator.of(context).pushReplacementNamed('/podium');
          }
        });
        
        return Column(
          children: [
            if (state.gameState.correctAnswerId != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Respuesta correcta: ${state.gameState.correctAnswerId}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kahootYellow)),
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