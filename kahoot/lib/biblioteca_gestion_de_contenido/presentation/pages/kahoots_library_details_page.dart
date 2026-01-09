import 'package:flutter/material.dart';
import '../../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../core/widgets/gradient_button.dart';

class LibraryKahootDetailsPage extends StatelessWidget {
  final Kahoot item;
  const LibraryKahootDetailsPage({Key? key, required this.item}) : super(key: key);

  static const Color bgBrown = Color(0xFF3A240C);
  static const Color cardYellow = Color(0xFFFFB300);
  static const Color lightYellow = Color(0xFFFFD36F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      appBar: AppBar(
        backgroundColor: cardYellow,
        elevation: 0,
        title: const Text('Detalles del Kahoot', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: BoxDecoration(
                color: cardYellow,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image area
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: lightYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: (item.image.isNotEmpty && item.image.startsWith('http'))
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.image,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.black45, size: 60),
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.black45, size: 60),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visibilidad: ${item.visibility == KahootVisibility.public ? 'Pública' : 'Privada'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        onTap: () {
                          // TODO: implementar flujo de crear sesión
                        },
                        child: const Text('Crear sesión', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 18),
                      GradientButton(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        onTap: () {
                          // TODO: implementar jugar en solitario
                        },
                        child: const Text('Jugar solitario', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
