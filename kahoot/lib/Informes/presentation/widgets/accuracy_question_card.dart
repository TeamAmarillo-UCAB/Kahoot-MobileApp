import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../../domain/entities/session_report.dart';

class AccuracyQuestionCard extends StatelessWidget {
  final QuestionAnalysisItem question;
  final int index;

  const AccuracyQuestionCard({
    super.key,
    required this.question,
    required this.index,
  });

  // Lógica del Semáforo
  Color _getTrafficLightColor(double percentage) {
    if (percentage >= 61) {
      return AppColors.successGreen; // Verde
    } else if (percentage >= 21) {
      return Colors.orange; // Naranja
    } else {
      return AppColors.errorRed; // Rojo
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTrafficLightColor(question.correctPercentage);
    
    // Aseguramos que sea entero para mostrar "85%" en vez de "85.0%"
    final percentageInt = question.correctPercentage.toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBrown, // Fondo Marrón
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 6), // Indicador lateral de color
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Row(
        children: [
          // Enunciado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pregunta ${index + 1}",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.questionText,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),

          // Badge de Porcentaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$percentageInt%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}