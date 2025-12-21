import 'package:flutter/material.dart';
import '../../domain/entities/slide.dart';
import '../utils/game_constants.dart';

class OptionTile extends StatelessWidget {
  final SlideOption option;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final index = int.parse(option.index);
    final color = GameColors.optionColors[index % GameColors.optionColors.length];

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: option.text != null
              ? Text(
                  option.text!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : Image.network(
                  option.mediaId!,
                  // TODO(GestionDeMultimedia): cache/preload
                ),
        ),
      ),
    );
  }
}
