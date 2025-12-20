import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../../domain/entities/attempt.dart';

class QuizView extends StatelessWidget {
  final Attempt attempt;
  const QuizView({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final slide = attempt.nextSlide!;
    final colors = [
      const Color(0xFFE21B3C),
      const Color(0xFF1368CE),
      const Color(0xFFD89E00),
      const Color(0xFF26890C),
    ];
    final icons = [
      Icons.change_history,
      Icons.stop_circle_outlined,
      Icons.circle_outlined,
      Icons.square_outlined,
    ];

    return Column(
      children: [
        // Indicador de progreso (ej: "1 de 4") [cite: 3, 8, 35, 56]
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Text(
            "${slide.currentNumber} de ${slide.totalQuestions}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              slide.questionText, // [cite: 14, 40, 64]
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Cuadrícula de opciones
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          padding: const EdgeInsets.all(8),
          children: List.generate(slide.options.length, (i) {
            return Card(
              color: colors[i % 4],
              child: InkWell(
                onTap: () => context.read<GameBloc>().add(
                  OnSubmitAnswer(answerIndexes: [i], timeSeconds: 10),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icons[i % 4], color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        slide.options[i].text ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        // Barra inferior del jugador [cite: 25, 27, 34, 52, 74]
        Container(
          color: Colors.black26,
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                attempt.playerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${attempt.currentScore}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
