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
              left: 8,
              top: 8,
              child: Icon(icon, color: Colors.white30, size: 28),
            ),
            if (isSelected)
              const Positioned(
                right: 8,
                top: 8,
                child: Icon(Icons.check_circle, color: Colors.white, size: 22),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 30, 12, 8),
                child: option.mediaId != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://quizzy-backend-0wh2.onrender.com/api/media/${option.mediaId}',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                color: Colors.white,
                              ),
                        ),
                      )
                    : Text(
                        option.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
