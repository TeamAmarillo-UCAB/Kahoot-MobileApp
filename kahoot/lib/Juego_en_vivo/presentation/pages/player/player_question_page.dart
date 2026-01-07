import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';
import 'player_results_page.dart'; // Asegúrate de que la ruta sea correcta

class PlayerQuestionPage extends StatefulWidget {
  const PlayerQuestionPage({super.key});

  @override
  State<PlayerQuestionPage> createState() => _PlayerQuestionPageState();
}

class _PlayerQuestionPageState extends State<PlayerQuestionPage> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();

    final state = context.read<LiveGameBloc>().state;
    _remainingSeconds = state.gameData?.currentSlide?.timeLimit ?? 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _handleAnswer(String optionIndex, String? questionId) {
    if (_answered) return;

    setState(() => _answered = true);
    _stopwatch.stop();
    _timer.cancel();

    final elapsedMs = _stopwatch.elapsedMilliseconds;

    context.read<LiveGameBloc>().add(
      SubmitAnswer(
        questionId: questionId ?? "",
        answerIds: [optionIndex],
        timeElapsedMs: elapsedMs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LiveGameBloc, LiveGameBlocState>(
      listener: (context, state) {
        // Navegar a resultados cuando el estado cambie a RESULTS
        if (state.status == LiveGameStatus.results) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<LiveGameBloc>(),
                child: const PlayerResultsView(),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<LiveGameBloc, LiveGameBlocState>(
        builder: (context, state) {
          // Pantalla intermedia: Respuesta enviada, esperando al Host
          if (state.status == LiveGameStatus.waitingResults) {
            return const Scaffold(
              backgroundColor: Color(0xFF46178F),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 24),
                    Text(
                      "¡Respuesta enviada!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Espera a que el anfitrión avance...",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          final slide = state.gameData?.currentSlide;
          final options = slide?.options ?? [];

          return Scaffold(
            backgroundColor: const Color(0xFF46178F),
            body: SafeArea(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: slide != null && slide.timeLimit > 0
                        ? _remainingSeconds / slide.timeLimit
                        : 0,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.cyanAccent,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pregunta ${slide?.questionIndex ?? 0}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.black26,
                          child: Text(
                            "$_remainingSeconds",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      slide?.questionText ?? "Cargando...",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (slide?.imageUrl != null)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            slide!.imageUrl!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        return _AnswerButton(
                          option: option,
                          color: _getKahootColor(index),
                          enabled: !_answered,
                          onTap: () => _handleAnswer(option.index, slide?.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getKahootColor(int index) {
    const colors = [Colors.red, Colors.blue, Colors.orange, Colors.green];
    return colors[index % colors.length];
  }
}

class _AnswerButton extends StatelessWidget {
  final dynamic option;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.option,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.6,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: option.text != null
              ? Text(
                  option.text!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              : (option.mediaUrl != null
                    ? Image.network(option.mediaUrl!)
                    : const Icon(Icons.help_outline, color: Colors.white)),
        ),
      ),
    );
  }
}
