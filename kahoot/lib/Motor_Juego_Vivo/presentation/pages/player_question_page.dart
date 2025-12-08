// lib/presentation/pages/player_question_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';

import '../widgets/answer_button.dart'; // Asumimos AnswerButton ya corregido
import '../widgets/timer_widget.dart';

// Clase auxiliar que define los colores y formas de los botones Kahoot!
class KahootColorsAndIcons {
  static const List<Color> colors = [
    Color(0xFFE53935), // Rojo
    Color(0xFF1E88E5), // Azul
    Color(0xFFFFB300), // Amarillo/Naranja
    Color(0xFF43A047), // Verde
  ];
  static const List<IconData> icons = [
    Icons.trip_origin, // Círculo
    Icons.square, // Cuadrado
    Icons.change_history, // Triángulo
    Icons.star, // Estrella/Rombo
  ];
}


class PlayerQuestionPage extends StatefulWidget {
  const PlayerQuestionPage({Key? key}) : super(key: key);

  @override
  State<PlayerQuestionPage> createState() => _PlayerQuestionPageState();
}

class _PlayerQuestionPageState extends State<PlayerQuestionPage> {
  DateTime? _start;
  // Bandera para evitar enviar múltiples respuestas o errores al navegar
  bool _answerSent = false; 

  void _onStart() {
    _start = DateTime.now();
    debugPrint("[PlayerQuestionPage] Timer started");
  }

  void _onAnswer(int answerIndex, String questionId) {
    if (_answerSent) return; // Evitar doble envío
    _answerSent = true;

    final end = DateTime.now();
    final elapsed = _start == null
        ? 0
        : end.difference(_start!).inMilliseconds;

    debugPrint(
        "[PlayerQuestionPage] ANSWER: index=$answerIndex questionId=$questionId elapsedMs=$elapsed");

    context.read<GameBloc>().add(GameEventSubmitAnswer(
          questionId: questionId,
          answerId: answerIndex,
          timeElapsedMs: elapsed,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final darkBackground = const Color(0xFF222222);
    final cardColor = Colors.grey.shade900;

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
          backgroundColor: darkBackground,
          title: const Text('Pregunta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<GameBloc, GameUiState>(
        builder: (context, state) {
          // Asumimos que state.gameState.currentSlide existe y tiene propiedades.
          // Si slide es null, el bloque 'if' lo maneja, por lo que podemos usar ! con precaución después.
          final slide = state.gameState.currentSlide; 

          if (slide == null) {
            debugPrint("[PlayerQuestionPage] ERROR: slide == null");
            return const Center(child: Text('Esperando datos de pregunta...', style: TextStyle(color: Colors.white70)));
          }

          // Navegación en caso de que el servidor pase de fase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!state.isQuestion) {
              if (state.isResults) {
                Navigator.of(context, rootNavigator: true)
                    .pushReplacementNamed('/player_results');
              }
              if (state.isEnd) {
                Navigator.of(context, rootNavigator: true).pushReplacementNamed('/podium');
              }
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarjeta superior con la pregunta
                Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.questionText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (slide.hasMedia) const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Timer
                TimerWidget(
                  seconds: slide.timeLimitSeconds,
                  onStart: _onStart,
                  onFinished: () {
                    debugPrint("[PlayerQuestionPage] Timer finished → auto submit");
                    _onAnswer(-1, slide.slideId); // -1 para respuesta automática por tiempo
                  },
                ),

                const SizedBox(height: 24),

                // Opciones de respuesta
                if (slide.options.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('La pregunta no tiene opciones válidas.', style: TextStyle(color: Colors.redAccent)),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: slide.options.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 2.5, 
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final opt = slide.options[index];
                      // Garantizamos un texto visible si la opción es nula o vacía
                      final visibleText = (opt.text == null || opt.text!.trim().isEmpty) ? 'Opción ${index + 1}' : opt.text!;

                      final color = KahootColorsAndIcons.colors[index % KahootColorsAndIcons.colors.length];
                      final icon = KahootColorsAndIcons.icons[index % KahootColorsAndIcons.icons.length];
                      
                      return AnswerButton(
                        text: visibleText,
                        color: color,
                        icon: icon,
                        // 🚀 CORRECCIÓN DEL CRASHEO DE NULIDAD:
                        // La propiedad onPressed debe ser null para deshabilitar el botón.
                        onPressed: _answerSent ? null : () { 
                          debugPrint("[PlayerQuestionPage] User pressed option ${opt.index}");
                          _onAnswer(opt.index, slide.slideId);
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}