import 'package:flutter/material.dart';

class GameAssets {
  static const String _base = 'assets/images/game';

  // Fondos
  static const String bgPink = '$_base/pink_game_background.png';
  static const String bgGreen = '$_base/green_game_background.png';
  static const String bgFall = '$_base/fall_game_background.png';
  static const String bgBlue = '$_base/blue_game_background.png';

  // Iconos
  static const String iconCorrect = '$_base/correct_answer_icon.png';
  static const String iconWrong = '$_base/wrong_answer_icon.png';
  static const String iconTrophy = '$_base/trophy_icon.png';
  
  // Iconos de tipos de pregunta
  static const String iconQuiz = '$_base/quiz_icon.png';
  static const String iconTrueFalse = '$_base/true_false_icon.png';
  static const String iconShortAnswer = '$_base/short_answer_icon.png';
  static const String iconSlide = '$_base/diapositiva_icon.png';
}

class GameColors {
  // Colores Kahoot clásicos
  static const Color red = Color(0xFFE21B3C);
  static const Color blue = Color(0xFF1368CE);
  static const Color yellow = Color(0xFFD89E00);
  static const Color green = Color(0xFF26890C);

  static const Color correctGreen = Color(0xFF66BF39);
  static const Color wrongRed = Color(0xFFFF3355);
  static const Color mainPurple = Color(0xFF46178F);

  // Orden específico: Azul, Rojo, Verde, Amarillo (se repite si hay más)
  static const List<Color> optionColors = [red, blue, yellow, green];

  // Formas clásicas para los botones
  static const List<IconData> optionIcons = [
    Icons.change_history, // Triángulo (Rojo)
    Icons.diamond,        // Rombo (Azul)
    Icons.circle,         // Círculo (Amarillo)
    Icons.square,         // Cuadrado (Verde)
  ];

  static Color getBackgroundForIndex(int index) {
     const backgrounds = [
       Color(0xFF46178F), // Morado base
       Color(0xFFB91E6A), // Rosa oscuro
       Color(0xFF1368CE), // Azul
     ];
     return backgrounds[index % backgrounds.length];
  }
}
