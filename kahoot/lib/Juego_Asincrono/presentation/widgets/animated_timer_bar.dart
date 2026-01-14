import 'package:flutter/material.dart';
import '../utils/game_constants.dart';

class AnimatedTimerBar extends StatelessWidget {
  final double progress;
  const AnimatedTimerBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 12, // Un poco más alto
      decoration: BoxDecoration(
        color: Colors.black12,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: const BoxDecoration(
            color: GameColors.amberTheme, 
            borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
          ),
        ),
      ),
    );
  }
}