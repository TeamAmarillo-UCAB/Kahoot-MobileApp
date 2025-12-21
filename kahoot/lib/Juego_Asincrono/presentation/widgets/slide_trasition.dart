import 'package:flutter/material.dart';

class KahootSlideTransition extends StatelessWidget {
  final Widget child;
  const KahootSlideTransition({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(position: slide, child: child);
      },
      child: child,
    );
  }
}
