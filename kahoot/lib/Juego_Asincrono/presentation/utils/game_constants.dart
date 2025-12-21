import 'package:flutter/material.dart';
import '../../domain/entities/slide.dart'; 

class GameAssets {
  static const String _base = 'assets/images/game';
  
  // --- FONDOS DE JUEGO (Temas) ---
  static const String bgPink = '$_base/pink_game_background.png';
  static const String bgGreen = '$_base/green_game_background.png';
  static const String bgFall = '$_base/fall_game_background.png'; // Atardecer
  static const String bgBlue = '$_base/blue_game_background.png';

  // --- ICONOS DE FEEDBACK ---
  static const String iconCorrect = '$_base/correct_answer_icon.png';
  static const String iconWrong = '$_base/wrong_answer_icon.png';
  static const String iconTrophy = '$_base/trophy_icon.png'; // Summary

  // --- ICONOS DE TIPO DE PREGUNTA ---
  static const String typeQuiz = '$_base/quiz_icon.png'; // Quiz y Multiple
  static const String typeTrueFalse = '$_base/true_false_icon.png';
  static const String typeShort = '$_base/short_answer_icon.png';
  static const String typeSlide = '$_base/diapositiva_icon.png';

  /// Retorna el icono según el tipo de pregunta
  static String getIconForType(QuestionType type) {
    switch (type) {
      case QuestionType.quiz_single:
      case QuestionType.quiz_multiple:
        return typeQuiz;
      case QuestionType.true_false:
        return typeTrueFalse;
      case QuestionType.short_answer:
        return typeShort;
      // Si agregaste 'slide' al enum úsalo, si no, el default cubre el caso 'slide'
      default: 
        return typeSlide; 
    }
  }

  /// Retorna un fondo aleatorio para la partida
  static String getRandomBackground() {
    final backgrounds = [bgPink, bgBlue, bgGreen, bgFall];
    return (backgrounds..shuffle()).first;
  }
}

class GameColors {
  // Colores oficiales de Kahoot para las opciones
  static const Color red = Color(0xFFE21B3C); // Triángulo
  static const Color blue = Color(0xFF1368CE); // Rombo
  static const Color yellow = Color(0xFFD89E00); // Círculo
  static const Color green = Color(0xFF26890C); // Cuadrado
  static const Color purple = Color(0xFF864CBF);
  static const Color turquoise = Color(0xFF00C4CC);

  // Colores para feedback de fondo (Importantes para FeedbackView)
  static const Color correctGreen = Color(0xFF66BF39); 
  static const Color wrongRed = Color(0xFFFF3355);

  // Orden según tu especificación: azul - rojo - verde - amarillo
  static const List<Color> optionColors = [
    blue,    // Index 0
    red,     // Index 1
    green,   // Index 2
    yellow,  // Index 3
    purple,  // Index 4
    turquoise // Index 5
  ];

  // Formas aproximadas para los iconos dentro de los botones
  static const List<IconData> optionIcons = [
    Icons.square,          // Azul (Aprox)
    Icons.change_history,  // Rojo
    Icons.circle,          // Verde
    Icons.square_outlined, // Amarillo
  ];
}

class GameMessages {
  static const List<String> correct = [
    "¡Más fácil que el mewing!",
    "¡Eres un genio!",
    "¡Facilito el tutorial!",
    "¡Sigue así!",
    "¡A romperla!",
  ];

  static const List<String> wrong = [
    "Skill issue",
    "¿Estás escuchando Linkin Park?",
    "Ups...",
    "A la próxima sale",
    "Se te chispoteó",
  ];

  static String getRandom(bool isCorrect) {
    return isCorrect 
      ? (correct..shuffle()).first 
      : (wrong..shuffle()).first;
  }
}