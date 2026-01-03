// import 'package:flutter/material.dart';

// class AnimatedTimerBar extends StatelessWidget {
//   final double progress;
//   const AnimatedTimerBar({super.key, required this.progress});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 10,
//       decoration: BoxDecoration(
//         color: Colors.white10,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: FractionallySizedBox(
//         alignment: Alignment.centerLeft,
//         widthFactor: progress.clamp(0.0, 1.0),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topRight: Radius.circular(5),
//               bottomRight: Radius.circular(5),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../utils/game_constants.dart';

class AnimatedTimerBar extends StatelessWidget {
  final double progress;
  const AnimatedTimerBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 12, // Un poco más alto
      decoration: BoxDecoration(
        color: Colors.black12,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: const BoxDecoration(
            color: GameColors.amberTheme, // AQUI EL CAMBIO
            borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
          ),
        ),
      ),
    );
  }
}