import 'package:flutter/material.dart';
import '../../domain/entities/slide.dart';
import '../utils/game_constants.dart';

class QuestionHeader extends StatelessWidget {
  final Slide slide;

  const QuestionHeader({
    super.key,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}
