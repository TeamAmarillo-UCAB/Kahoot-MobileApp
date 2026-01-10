import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para Clipboard

class InviteSuccessDialog extends StatelessWidget {
  final String link;

  const InviteSuccessDialog({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          // Icono opcional para darle más estilo visual
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.blue, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            "Invitar miembros",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Comparte el link con tus amigos para que se puedan unir:",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Contenedor del Link (Estilo visual similar al de un input readonly)
          InkWell(
            onTap: () => _copyToClipboard(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      link,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.copy, size: 20, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.only(
        bottom: 24,
        left: 24,
        right: 24,
        top: 0,
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _copyToClipboard(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Copiar Link",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text("Cerrar"),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: link));
    Navigator.pop(context); // Cierra el diálogo tras copiar

    // Muestra feedback al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("¡Link copiado al portapapeles!"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ),
    );
  }
}
