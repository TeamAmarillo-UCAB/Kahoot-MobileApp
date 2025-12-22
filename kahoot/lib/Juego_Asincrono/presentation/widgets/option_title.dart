import 'package:flutter/material.dart';
import '../../domain/entities/slide.dart';
import '../utils/game_constants.dart';

class OptionTitle extends StatelessWidget {
  final Option option;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionTitle({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        GameColors.optionColors[option.index % GameColors.optionColors.length];
    final icon =
        GameColors.optionIcons[option.index % GameColors.optionIcons.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.white, width: 5) : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 10,
              child: Icon(icon, color: Colors.white30, size: 35),
            ),
            if (isSelected)
              const Positioned(
                right: 10,
                top: 10,
                child: Icon(Icons.check_circle, color: Colors.white, size: 28),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  option.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
