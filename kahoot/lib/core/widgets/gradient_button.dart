import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  const GradientButton({
    Key? key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF5A437), // naranja
              Color(0xFF8B5A2B), // marrón
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B3A17).withOpacity(0.35),
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              offset: const Offset(0, 3),
              blurRadius: 7,
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}
