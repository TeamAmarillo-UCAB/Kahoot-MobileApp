import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_state.dart';

class PlayerResultsView extends StatelessWidget {
  const PlayerResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        final int score = state.gameData?.totalScore ?? 0;
        final int rank = state.gameData?.rank ?? 0;

        return Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tu puntuación actual:',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const Divider(indent: 50, endIndent: 50, height: 40),
                const Text(
                  'Estás en la posición:',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  '#$rank',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Mira la pantalla principal para ver los resultados globales',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
