import 'package:flutter/material.dart';

class AnimatedTimerBar extends StatelessWidget {
  final double progress;
  const AnimatedTimerBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress.clamp(0.0, 1.0),
      minHeight: 6,
      backgroundColor: Colors.white24,
      valueColor: const AlwaysStoppedAnimation(Colors.white),
    );
  }
}
