import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../../domain/entities/player_result_detail.dart';

class QuestionResultCard extends StatelessWidget {
  final QuestionResultItem item; // Entidad interna del detalle
  final int index;

  const QuestionResultCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = item.isCorrect ? AppColors.successGreen : AppColors.errorRed;
    final iconData = item.isCorrect ? Icons.check_circle : Icons.cancel;
    final iconColor = item.isCorrect ? AppColors.successGreen : AppColors.errorRed;

    // Detectamos qué tipo de respuesta tenemos
    final bool hasText = item.answerText.isNotEmpty;
    final bool hasImages = item.answerMediaId.isNotEmpty;
    final bool hasAnswer = hasText || hasImages;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBrown, // Fondo Marrón
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 3, // Borde grueso para feedback visual claro
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Cabecera: Pregunta + Icono Feedback ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "${index + 1}. ${item.questionText}",
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(iconData, color: iconColor, size: 28),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),

          // --- Sección de Respuesta del Usuario ---
          const Text(
            "Tu respuesta:",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          
          const SizedBox(height: 4),

          if (!hasAnswer)
            // Caso 1: No respondió (Tiempo agotado)
            const Text(
              "Sin respuesta (Tiempo agotado)",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            // Caso 2: Tiene Texto y/o Imágenes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Renderizar Textos (si existen)
                if (hasText)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      item.answerText.join(", "),
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Renderizar Imágenes (si existen)
                if (hasImages)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.answerMediaId.map((url) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Colors.black12, // Placeholder bg
                          height: 100,
                          width: 100,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, color: Colors.white54),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryYellow, 
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          
          const SizedBox(height: 12),
          
          // --- Tiempo ---
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "${(item.timeTakenMs / 1000).toStringAsFixed(1)}s",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}