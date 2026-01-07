import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_state.dart';

class PlayerFeedbackView extends StatelessWidget {
  const PlayerFeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        final data = state.gameData;
        final bool isCorrect = data?.lastWasCorrect ?? false;

        return Scaffold(
          backgroundColor: isCorrect ? Colors.green[600] : Colors.red[600],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nota: 'message' y 'streak' no están en tu entidad actual.
                // Si los agregas a la entidad LiveGameState, podrás usarlos aquí.
                const SizedBox(height: 20),
                Icon(
                  isCorrect ? Icons.check_circle_outline : Icons.highlight_off,
                  size: 140,
                  color: Colors.white,
                ),
                Text(
                  isCorrect ? '¡CORRECTO!' : 'INCORRECTO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900, // Corregido
                  ),
                ),
                if (isCorrect) ...[
                  const SizedBox(height: 10),
                  Text(
                    '+${data?.lastPointsEarned ?? 0} puntos',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Puntaje total: ${data?.totalScore ?? 0}',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
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
