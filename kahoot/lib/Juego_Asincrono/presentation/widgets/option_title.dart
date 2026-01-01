import 'package:flutter/material.dart';
import '../../domain/entities/slide.dart';
import '../utils/game_constants.dart';

class OptionTitle extends StatelessWidget {
  final Option option;
  final int index; // 0, 1, 2, 3
  final bool isSelected;
  final VoidCallback onTap;

  const OptionTitle({
    super.key,
    required this.option,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener color e icono basado en la posición (0=Rojo/Triangulo, 1=Azul/Rombo...)
    final color = GameColors.optionColors[index % GameColors.optionColors.length];
    final iconData = GameColors.optionIcons[index % GameColors.optionIcons.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4), // Bordes más rectos estilo tarjeta
          // Efecto de "presionado" u opacidad si hay otro seleccionado
          border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 0, // Sombra sólida tipo bloque
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de forma (Triangulo, Cuadrado...)
            Align(
              alignment: Alignment.topLeft,
              child: Icon(iconData, color: Colors.white.withOpacity(0.5), size: 24),
            ),
            
            Expanded(
              child: Center(
                child: option.mediaId != null 
                ? Image.network(
                    'https://quizzy-backend-0wh2.onrender.com/api/media/${option.mediaId}',
                    fit: BoxFit.contain,
                  )
                : Text(
                    option.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(1,1), blurRadius: 2)]
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}