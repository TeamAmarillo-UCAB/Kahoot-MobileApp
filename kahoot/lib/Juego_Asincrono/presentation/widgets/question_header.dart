import 'package:flutter/material.dart';
import '../../domain/entities/slide.dart';

class QuestionHeader extends StatelessWidget {
  final Slide slide;
  final int currentNumber;
  final int totalQuestions;

  const QuestionHeader({
    super.key,
    required this.slide,
    required this.currentNumber,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black12,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pregunta $currentNumber",
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (totalQuestions > 0)
                Text(
                  "de $totalQuestions",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            slide.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
