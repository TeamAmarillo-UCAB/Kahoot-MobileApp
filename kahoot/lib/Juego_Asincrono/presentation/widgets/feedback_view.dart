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
    _timer = Timer(const Duration(seconds: 3), () {
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

    final message = widget.wasCorrect
        ? "¡Sigue así!"
        : "No te preocupes, sigue avanzando";

    // Determinamos el texto de puntos a mostrar
    final pointsText = widget.wasCorrect
        ? "+ ${widget.attempt.lastPointsEarned} puntos"
        : "+ 0 puntos";

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
            const SizedBox(height: 10),
            Text(
              widget.wasCorrect ? "CORRECTO" : "INCORRECTO",
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // PUNTOS GANADOS (Ahora siempre visible)
            Text(
              pointsText,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
