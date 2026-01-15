import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../../domain/entities/session_report.dart';

class RankingListItem extends StatelessWidget {
  final PlayerRankingItem player;
  final bool showPoints; // true = Puntos, false = Aciertos
  final int maxScore;    // Para calcular el % de la barra en modo Puntos
  final int totalQuestions; // Para calcular el % de la barra en modo Aciertos

  const RankingListItem({
    super.key,
    required this.player,
    required this.showPoints,
    required this.maxScore,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calcular el porcentaje para la barra de progreso (0.0 a 1.0)
    double progress = 0.0;
    String valueText = "";

    if (showPoints) {
      // Evitar división por cero
      progress = maxScore > 0 ? player.score / maxScore : 0.0;
      valueText = "${player.score} pts";
    } else {
      progress = totalQuestions > 0 ? player.correctAnswers / totalQuestions : 0.0;
      valueText = "${player.correctAnswers}/$totalQuestions";
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Fondo sutil
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // --- Columna 1: Posición ---
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getPositionColor(player.position),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "${player.position}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack, // Texto negro sobre circulo de color
              ),
            ),
          ),
          
          const SizedBox(width: 12),

          // --- Columna 2: Nombre y Barra Visual ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.username,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Barra de progreso visual
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black26,
                    // Usamos amarillo para puntos, verde para aciertos para diferenciar visualmente
                    valueColor: AlwaysStoppedAnimation<Color>(
                      showPoints ? AppColors.primaryYellow : AppColors.successGreen
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // --- Columna 3: Valor Numérico ---
          SizedBox(
            width: 80, // Ancho fijo para alineación
            child: Text(
              valueText,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Color distintivo para el Top 3
  Color _getPositionColor(int pos) {
    switch (pos) {
      case 1: return AppColors.primaryYellow; // Oro
      case 2: return const Color(0xFFC0C0C0); // Plata
      case 3: return const Color(0xFFCD7F32); // Bronce
      default: return Colors.white54;         // Resto
    }
  }
}