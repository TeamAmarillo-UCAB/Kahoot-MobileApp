import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../../domain/entities/attempt.dart';

class FeedbackView extends StatelessWidget {
  final Attempt attempt;
  const FeedbackView({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final isCorrect = attempt.lastWasCorrect ?? false;

    return Container(
      color: isCorrect ? const Color(0xFF26890C) : const Color(0xFFE21B3C),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isCorrect ? "CORRECTO" : "INCORRECTO", //
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "+ ${attempt.lastPointsEarned}", // [cite: 20, 33, 48, 76]
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
          const SizedBox(height: 10),
          Text(
            attempt.feedbackMessage ?? "", // [cite: 23, 33, 49, 76]
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.read<GameBloc>().add(OnNextQuestion()),
            child: const Text("SIGUIENTE"),
          ),
        ],
      ),
    );
  }
}
