import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/answer_button.dart';
import '../widgets/timer_widget.dart';

class PlayerQuestionPage extends StatefulWidget {
  const PlayerQuestionPage({Key? key}) : super(key: key);

  @override
  State<PlayerQuestionPage> createState() => _PlayerQuestionPageState();
}

class _PlayerQuestionPageState extends State<PlayerQuestionPage> {
  DateTime? _start;

  void _onStart() {
    _start = DateTime.now();
    print("[PlayerQuestionPage] Timer started");
  }

  void _onAnswer(int answerIndex, String questionId) {
    final end = DateTime.now();
    final elapsed = _start == null
        ? 0
        : end.difference(_start!).inMilliseconds;

    print(
        "[PlayerQuestionPage] ANSWER: index=$answerIndex questionId=$questionId elapsedMs=$elapsed");

    context.read<GameBloc>().add(GameEventSubmitAnswer(
          questionId: questionId,
          answerId: answerIndex,
          timeElapsedMs: elapsed,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pregunta')),
      body: BlocBuilder<GameBloc, GameUiState>(
        builder: (context, state) {
          final slide = state.gameState.currentSlide;

          if (slide == null) {
            print("[PlayerQuestionPage] ERROR: slide == null");
            return const Center(child: Text('No hay pregunta'));
          }

          print(
              '[PlayerQuestionPage] Rendering question: "${slide.questionText}"');

          // Si ya no estamos en fase de pregunta, navegamos
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!state.isQuestion) {
              if (state.isResults) {
                Navigator.of(context)
                    .pushReplacementNamed('/player_results');
              }
              if (state.isEnd) {
                Navigator.of(context).pushReplacementNamed('/podium');
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
                          ),
                        ),
                        if (slide.hasMedia) const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Timer
                TimerWidget(
                  seconds: slide.timeLimitSeconds,
                  onStart: _onStart,
                  onFinished: () {
                    print("[PlayerQuestionPage] Timer finished → auto submit");
                    _onAnswer(-1, slide.slideId);
                  },
                ),

                const SizedBox(height: 16),

                // Opciones de respuesta
                ...slide.options.map((opt) {
                  final visibleText = (opt.text == null ||
                          opt.text!.trim().isEmpty)
                      ? 'Opción ${opt.index + 1}'
                      : opt.text!;

                  print(
                      "[PlayerQuestionPage] option[${opt.index}] text='$visibleText' raw='${opt.text}'");

                  return AnswerButton(
                    text: visibleText,
                    onPressed: () {
                      print(
                          "[PlayerQuestionPage] User pressed option ${opt.index}");
                      _onAnswer(opt.index, slide.slideId);
                    },
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}