import 'package:flutter/material.dart';

class GameAssets {
  static const String _base = 'assets/images/game';

  static const String bgPink = '$_base/pink_game_background.png';
  static const String bgGreen = '$_base/green_game_background.png';
  static const String bgFall = '$_base/fall_game_background.png';
  static const String bgBlue = '$_base/blue_game_background.png';

  static const String iconCorrect = '$_base/correct_answer_icon.png';
  static const String iconWrong = '$_base/wrong_answer_icon.png';
  static const String iconTrophy = '$_base/trophy_icon.png';
}

class GameColors {
  static const Color red = Color(0xFFE21B3C);
  static const Color blue = Color(0xFF1368CE);
  static const Color yellow = Color(0xFFD89E00);
  static const Color green = Color(0xFF26890C);

  static const Color correctGreen = Color(0xFF66BF39);
  static const Color wrongRed = Color(0xFFFF3355);

  static const List<Color> optionColors = [blue, red, green, yellow];

  static const List<IconData> optionIcons = [
    Icons.square,
    Icons.change_history,
    Icons.circle,
    Icons.square_outlined,
  ];
}
