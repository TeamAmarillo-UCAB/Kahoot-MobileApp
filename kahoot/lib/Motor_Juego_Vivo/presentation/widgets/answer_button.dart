// lib/widgets/answer_button.dart - CORREGIDO

import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String text;
  // Acepta VoidCallback? para deshabilitar el botón (como se hizo en la respuesta anterior)
  final VoidCallback? onPressed; 
  final Color color; 
  final IconData icon; 

  const AnswerButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = color; 
    final fgColor = Colors.white; 

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: SizedBox(
        height: 60, 
        child: ElevatedButton.icon( 
          icon: Icon(icon, color: fgColor),
          // 🚀 CORRECCIÓN: Eliminamos Expanded. 
          // Usamos Flexible y Align para manejar el texto.
          label: Flexible( 
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                overflow: TextOverflow.ellipsis, // Mejor usar ellipsis
                softWrap: true,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: onPressed, // Usamos la propiedad nullable corregida.
        ),
      ),
    );
  }
}