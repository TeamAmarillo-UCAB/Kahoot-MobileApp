import 'package:flutter/material.dart';
import '../../domain/entities/slide.dart';
import '../utils/game_constants.dart';

class OptionTitle extends StatelessWidget {
  final Option option;
  final int index;
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
    // Obtener color e icono
    final color = GameColors.optionColors[index % GameColors.optionColors.length];
    final iconData = GameColors.optionIcons[index % GameColors.optionIcons.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        // Padding reducido para dar máximo espacio al contenido
        padding: const EdgeInsets.all(8), 
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 0, 
            )
          ],
        ),
        // CAMBIO PRINCIPAL: Usamos Stack en lugar de Column
        child: Stack(
          children: [
            // 1. Icono (Anclado arriba a la izquierda)
            Positioned(
              left: 0,
              top: 0,
              child: Icon(iconData, color: Colors.white.withOpacity(0.9), size: 18),
            ),

            // 2. Contenido (Texto o Imagen) Centrado absolutamente en la tarjeta
            Center(
              child: Padding(
                // Damos un poco de margen horizontal para que no toque los bordes
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: option.mediaId != null 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        'https://quizzy-backend-0wh2.onrender.com/api/media/${option.mediaId}',
                        fit: BoxFit.cover,
                        width: double.infinity, // Asegura que ocupe espacio disponible
                      ),
                    )
                  : Text(
                      option.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15, // Tamaño 15 es ideal para hasta 75 chars
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black26, offset: Offset(1,1), blurRadius: 2)]
                      ),
                      maxLines: 5, // Aumentado a 5 líneas para soportar 75 caracteres cómodamente
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