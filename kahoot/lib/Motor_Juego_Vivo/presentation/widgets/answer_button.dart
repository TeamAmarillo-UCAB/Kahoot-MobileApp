import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AnswerButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary, // 👈 TEXTO AHORA ES VISIBLE
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: onPressed,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              overflow: TextOverflow.visible,   // 👈 evita ocultar texto
              softWrap: true,                   // 👈 permite multilínea
            ),
          ),
        ),
      ),
    );
  }
}
