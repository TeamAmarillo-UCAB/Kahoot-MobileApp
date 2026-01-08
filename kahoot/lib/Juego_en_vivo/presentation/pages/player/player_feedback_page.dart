import 'package:flutter/material.dart';
import '../../bloc/live_game_state.dart';

class PlayerFeedbackView extends StatelessWidget {
  final LiveGameBlocState state;
  const PlayerFeedbackView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final bool isCorrect = data?.lastWasCorrect ?? false;

    return Container(
      color: isCorrect ? Colors.green[600] : Colors.red[600],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                fontWeight: FontWeight.w900,
              ),
            ),
            if (isCorrect)
              Text(
                '+${data?.lastPointsEarned ?? 0} puntos',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
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
  }
}
