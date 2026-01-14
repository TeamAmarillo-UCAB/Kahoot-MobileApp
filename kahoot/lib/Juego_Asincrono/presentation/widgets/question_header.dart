import 'package:flutter/material.dart';
import '../../domain/entities/slide.dart';
import '../utils/game_constants.dart';

class QuestionHeader extends StatelessWidget {
  final int currentNumber;
  final Slide slide;

  const QuestionHeader({
    super.key,
    required this.currentNumber,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    String iconPath = GameAssets.iconQuiz;
    String typeText = "Quiz";

    switch (slide.type) {
      case 'TRUE_FALSE':
        iconPath = GameAssets.iconTrueFalse;
        typeText = "Verdadero/Falso";
        break;
      case 'SHORT_ANSWER':
        iconPath = GameAssets.iconShortAnswer;
        typeText = "Respuesta Corta";
        break;
      case 'SLIDE':
        iconPath = GameAssets.iconSlide;
        typeText = "Diapositiva";
        break;
      case 'MULTIPLE':
        iconPath = GameAssets.iconQuiz;
        typeText = "Quiz Múltiple";
        break;
      default:
        iconPath = GameAssets.iconQuiz;
        typeText = "Quiz";
        break;
    }

    return Container(
      height: 60, // Altura fija para el header
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.black12, // Fondo semitransparente oscuro general
      child: Stack(
        alignment: Alignment.centerLeft, // Alineación por defecto para hijos del stack
        children: [
          // 1. Número de pregunta (Anclado a la izquierda)
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "$currentNumber",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),

          // 2. Contenido Central (Icono + Texto en marco blanco)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white, // Fondo blanco
                borderRadius: BorderRadius.circular(25), // Bordes muy redondeados
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
                children: [
                  // Icono
                  Image.asset(
                    iconPath, 
                    width: 26, 
                    height: 26,
                    // Si falla, icono morado de respaldo
                    errorBuilder: (_,__,___) => const Icon(Icons.category, color: Colors.black87, size: 26),
                  ),

                  const SizedBox(width: 10),

                  // Texto (Ahora en color morado para contraste sobre blanco)
                  Text(
                    typeText,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.black87, // Color morado
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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