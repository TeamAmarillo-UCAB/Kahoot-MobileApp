import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attempt.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../utils/game_constants.dart';

class FeedbackView extends StatefulWidget {
  final Attempt attempt;
  final bool wasCorrect;

  const FeedbackView({
    super.key,
    required this.attempt,
    required this.wasCorrect,
  });

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<GameBloc>().add(OnNextQuestion());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.wasCorrect
        ? GameColors.correctGreen
        : GameColors.wrongRed;

    return Material(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.wasCorrect
                  ? Icons.check_circle_outline
                  : Icons.highlight_off,
              size: 150,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              widget.wasCorrect ? "CORRECTO" : "INCORRECTO",
              style: const TextStyle(
                fontSize: 45,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "Puntaje: ${widget.attempt.currentScore}",
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
