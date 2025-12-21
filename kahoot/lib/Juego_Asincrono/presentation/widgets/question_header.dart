import 'package:flutter/material.dart';
import '../../domain/entities/slide.dart';
import '../utils/game_constants.dart';

class QuestionHeader extends StatelessWidget {
  final Slide slide;

  const QuestionHeader({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          // 👈 Cambiamos a Column para poner la pregunta abajo
          mainAxisSize: MainAxisSize.min,
          children: [
            // FILA SUPERIOR: Progreso e Icono
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Progreso: "1 de 4"
                Text(
                  '${slide.currentNumber} de ${slide.totalQuestions}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Icono del tipo de pregunta
                Image.asset(
                  GameAssets.getIconForType(slide.type),
                  height: 28,
                  // Si no tienes los assets aún, puedes comentar esta línea y usar:
                  // child: Icon(Icons.help_outline, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 24), // Espacio entre el header y la pregunta
            // --- ESTO ES LO QUE FALTABA: EL TEXTO DE LA PREGUNTA ---
            Text(
              slide.questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black26,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
