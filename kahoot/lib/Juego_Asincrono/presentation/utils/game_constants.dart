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
  static const Color red = Color(0xFFE21B3C);
  static const Color blue = Color(0xFF1368CE);
  static const Color yellow = Color(0xFFD89E00);
  static const Color green = Color(0xFF26890C);

  static const Color correctGreen = Color(0xFF66BF39);
  static const Color wrongRed = Color(0xFFFF3355);
  static const Color mainPurple = Color(0xFF46178F);
  
  // Nuevo color Amber para la app/timer
  static const Color amberTheme = Color(0xFFFFC107); 

  static const List<Color> optionColors = [red, blue, yellow, green];

  // Usamos iconos rellenos (rounded/sharp) para simular el look sólido
  static const List<IconData> optionIcons = [
    Icons.change_history, // Triángulo (Se renderizará solido o grueso)
    Icons.diamond,        // Rombo
    Icons.circle,         // Círculo (Relleno)
    Icons.square,         // Cuadrado (Relleno)
  ];
}

class GameTextStyles {
  // Asegúrate de tener la fuente Montserrat en tu pubspec.yaml o usa esta configuración
  static const TextStyle montserrat = TextStyle(
    fontFamily: 'Montserrat', // Si no carga, usará la default
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle questionHeader = montserrat.copyWith(
    fontSize: 20, 
    color: Colors.white,
    fontWeight: FontWeight.bold
  );

  static TextStyle questionText = montserrat.copyWith(
    fontSize: 22,
    color: Colors.white,
    fontWeight: FontWeight.w700,
  );
  
  static TextStyle optionText = montserrat.copyWith(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w700,
  );
}