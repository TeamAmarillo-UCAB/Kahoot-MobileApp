import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attempt.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../utils/game_constants.dart';

class FeedbackView extends StatefulWidget {
  final Attempt attempt;
  const FeedbackView({super.key, required this.attempt});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      context.read<GameBloc>().add(OnNextQuestion());
    });
  }

  @override
  Widget build(BuildContext context) {
    final correct = widget.attempt.lastWasCorrect ?? false;
    final color = correct
        ? GameColors.correctGreen
        : GameColors.wrongRed;

    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              correct ? Icons.check_circle : Icons.cancel,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              correct ? "CORRECTO" : "INCORRECTO",
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "+${widget.attempt.lastPointsEarned}",
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
