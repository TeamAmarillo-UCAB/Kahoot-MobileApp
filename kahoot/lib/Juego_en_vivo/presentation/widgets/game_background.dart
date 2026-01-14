import 'package:flutter/material.dart';

class GameBackground extends StatelessWidget {
  final String? imageUrl;

  static const Color _defaultYellow = Color(0xFFFFC107);

  const GameBackground({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Positioned.fill(child: Container(color: _defaultYellow));
    }

    return Positioned.fill(
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: _defaultYellow),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : Container(color: _defaultYellow),
      ),
    );
  }
}
