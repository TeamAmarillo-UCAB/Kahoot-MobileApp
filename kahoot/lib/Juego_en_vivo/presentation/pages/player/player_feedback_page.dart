import 'package:flutter/material.dart';
import '../../bloc/live_game_state.dart';

class PlayerFeedbackView extends StatelessWidget {
  final LiveGameBlocState state;
  const PlayerFeedbackView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final bool isCorrect = data?.lastWasCorrect ?? false;
    final int points = data?.lastPointsEarned ?? 0;
    final String message =
        data?.feedbackMessage ??
        (isCorrect ? "¡Buen trabajo!" : "¡A la próxima!");

    // Colores basados en el resultado
    final Color mainColor = isCorrect
        ? const Color(0xFF66BF39)
        : const Color(0xFFEB1D3F);

    return Container(
      width: double.infinity,
      color: mainColor,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isCorrect ? "¡CORRECTO!" : "INCORRECTO",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),

            // Icono animado
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white24,
              child: Icon(
                isCorrect ? Icons.check : Icons.close,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // Puntos ganados
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isCorrect ? "+$points" : "+0",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Mensaje motivacional del servidor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            // Footer con Racha y Puesto
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoColumn(label: "RACHA", value: "${data?.streak ?? 0} 🔥"),
                  _InfoColumn(label: "PUESTO", value: "#${data?.rank ?? 0}"),
                  _InfoColumn(
                    label: "TOTAL",
                    value: "${data?.totalScore ?? 0}",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
