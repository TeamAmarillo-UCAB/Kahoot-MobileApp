// lib/presentation/pages/player/player_results_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_state.dart';
import 'player_question_page.dart';

class PlayerResultsView extends StatelessWidget {
  const PlayerResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LiveGameBloc, LiveGameBlocState>(
      listener: (context, state) {
        if (state.status == LiveGameStatus.question) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<LiveGameBloc>(),
                child: const PlayerQuestionPage(),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<LiveGameBloc, LiveGameBlocState>(
        builder: (context, state) {
          final game = state.gameData;
          final int totalScore = game?.totalScore ?? 0;
          final int roundPoints = game?.lastPointsEarned ?? 0;
          final int rank = game?.rank ?? 0;
          final bool isCorrect = game?.lastWasCorrect ?? false;
          final String feedback =
              game?.feedbackMessage ??
              (isCorrect ? "¡Excelente!" : "¡Sigue intentando!");

          return Scaffold(
            backgroundColor: isCorrect
                ? const Color(0xFF66BF39)
                : const Color(0xFFFF3355),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isCorrect ? '¡CORRECTO!' : '¡INCORRECTO!',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Puntos de esta ronda
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+$roundPoints pts',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Puntuación total:',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    Text(
                      '$totalScore',
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Divider(
                      indent: 80,
                      endIndent: 80,
                      height: 40,
                      color: Colors.white24,
                    ),
                    Text(
                      'Posición: #$rank',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        feedback,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
