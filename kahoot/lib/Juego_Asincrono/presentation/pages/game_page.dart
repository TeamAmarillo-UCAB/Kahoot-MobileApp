// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/game_bloc.dart';
// import '../blocs/game_state.dart';
// import '../blocs/game_event.dart';
// import '../widgets/quiz_view.dart';
// import '../widgets/feedback_view.dart';
// import '../widgets/slide_trasition.dart';
// import 'game_summary_page.dart';

// class GamePage extends StatelessWidget {
//   final String kahootId;
//   const GamePage({super.key, required this.kahootId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF46178F),
//       body: BlocBuilder<GameBloc, GameState>(
//         builder: (context, state) {
//           return KahootSlideTransition(
//             child: _buildStateWrapper(context, state),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStateWrapper(BuildContext context, GameState state) {
//     if (state is GameLoading) {
//       return const Center(
//         key: ValueKey('loading_state'),
//         child: CircularProgressIndicator(color: Colors.white),
//       );
//     }

//     if (state is QuizState) {
//       return QuizView(
//         key: ValueKey('quiz_${state.currentNumber}'),
//         attempt: state.attempt,
//         currentNumber: state.currentNumber,
//         totalQuestions: state.totalQuestions,
//       );
//     }

//     if (state is ShowingFeedback) {
//       return FeedbackView(
//         key: const ValueKey('feedback_state'),
//         attempt: state.attempt,
//         wasCorrect: state.wasCorrect,
//       );
//     }

//     if (state is GameSummaryState) {
//       return GameSummaryPage(
//         key: const ValueKey('summary_state'),
//         summary: state.summary,
//       );
//     }

//     if (state is GameError) {
//       return Center(
//         key: const ValueKey('error_state'),
//         child: _ErrorBody(message: state.message, kahootId: kahootId),
//       );
//     }

//     return const SizedBox.shrink(key: ValueKey('empty_state'));
//   }
// }

// class _ErrorBody extends StatelessWidget {
//   final String message;
//   final String kahootId;
//   const _ErrorBody({required this.message, required this.kahootId});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, color: Colors.white, size: 80),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: const TextStyle(color: Colors.white, fontSize: 18),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () =>
//                 context.read<GameBloc>().add(OnStartGame(kahootId)),
//             child: const Text("Reintentar"),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_event.dart';
import '../widgets/quiz_view.dart';
import '../widgets/feedback_view.dart';
import 'game_summary_page.dart';
import '../utils/game_constants.dart';

class GamePage extends StatefulWidget {
  final String kahootId;
  const GamePage({super.key, required this.kahootId});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Variable para guardar el asset del fondo seleccionado aleatoriamente
  late String _currentBackground;
  
  @override
  void initState() {
    super.initState();
    // Elegir un fondo aleatorio al entrar a la pantalla
    final bgs = [
      GameAssets.bgBlue, 
      GameAssets.bgPink, 
      GameAssets.bgGreen, 
      GameAssets.bgFall
    ];
    _currentBackground = bgs[Random().nextInt(bgs.length)];
  }

  // Menú modal inferior para salir o cancelar
  void _showExitMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: GameColors.wrongRed),
              title: const Text(
                "Salir del juego", 
                style: TextStyle(fontWeight: FontWeight.bold, color: GameColors.wrongRed)
              ),
              onTap: () {
                Navigator.pop(ctx); // Cerrar el modal
                Navigator.pop(context); // Salir de la GamePage
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Cancelar"),
              onTap: () => Navigator.pop(ctx), // Solo cerrar el modal
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Permite que el fondo suba hasta el status bar
      
      // AppBar transparente solo para el botón de opciones (...)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Quitamos la flecha "Atrás" por defecto
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            decoration: const BoxDecoration(
              color: Colors.black26, // Fondo semitransparente para el botón
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: () => _showExitMenu(context),
            ),
          )
        ],
      ),
      
      body: Stack(
        children: [
          // 1. Imagen de Fondo Global
          Positioned.fill(
            child: Image.asset(
              _currentBackground,
              fit: BoxFit.cover,
              // Fallback por si la imagen falla
              errorBuilder: (_,__,___) => Container(color: GameColors.mainPurple),
            ),
          ),
          
          // 2. Contenido Principal (Manejado por el Bloc)
          SafeArea(
            child: BlocConsumer<GameBloc, GameState>(
              listener: (context, state) {
                // Aquí puedes agregar lógica extra si la necesitas (ej. sonidos)
              },
              builder: (context, state) {
                // AnimatedSwitcher hace una transición suave entre estados
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _buildStateWrapper(context, state),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateWrapper(BuildContext context, GameState state) {
    // ESTADO: CARGANDO
    if (state is GameLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // ESTADO: JUGANDO (PREGUNTA)
    if (state is QuizState) {
      // Usamos el número de pregunta en la Key para forzar que Flutter
      // redibuje el widget y ejecute la animación de entrada en cada pregunta.
      return QuizView(
        key: ValueKey('quiz_${state.currentNumber}'), 
        attempt: state.attempt,
        currentNumber: state.currentNumber,
        totalQuestions: state.totalQuestions,
      );
    }

    // ESTADO: FEEDBACK (CORRECTO/INCORRECTO)
    if (state is ShowingFeedback) {
      return FeedbackView(
        key: const ValueKey('feedback'),
        attempt: state.attempt,
        wasCorrect: state.wasCorrect,
      );
    }

    // ESTADO: RESUMEN FINAL
    if (state is GameSummaryState) {
      return GameSummaryPage(
        key: const ValueKey('summary'),
        summary: state.summary,
      );
    }

    // ESTADO: ERROR
    if (state is GameError) {
      return Center(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 80),
              const SizedBox(height: 16),
              Text(
                state.message,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Botón REINTENTAR (Recuperado del código original)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: GameColors.mainPurple,
                ),
                onPressed: () =>
                    context.read<GameBloc>().add(OnStartGame(widget.kahootId)),
                child: const Text("Reintentar"),
              ),
              
              const SizedBox(height: 12),
              
              // Botón SALIR
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Salir", 
                  style: TextStyle(color: Colors.white70)
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}