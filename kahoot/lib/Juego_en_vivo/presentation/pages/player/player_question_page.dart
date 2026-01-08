import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';

class PlayerQuestionView extends StatefulWidget {
  final LiveGameBlocState state;
  const PlayerQuestionView({super.key, required this.state});

  @override
  State<PlayerQuestionView> createState() => _PlayerQuestionViewState();
}

class _PlayerQuestionViewState extends State<PlayerQuestionView> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  int _remainingSeconds = 0;
  final Set<String> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _remainingSeconds = widget.state.gameData?.currentSlide?.timeLimit ?? 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
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

  void _submit(String? questionId, List<String> answers) {
    if (answers.isEmpty) return;
    context.read<LiveGameBloc>().add(
      SubmitAnswer(
        questionId: questionId ?? "",
        answerIds: answers,
        timeElapsedMs: _stopwatch.elapsedMilliseconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si el estado es waitingResults, mostramos el overlay de "Enviado"
    if (widget.state.status == LiveGameStatus.waitingResults) {
      return Container(
        color: const Color(0xFF46178F),
        child: const Center(
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
                "Espera al anfitrión...",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    final slide = widget.state.gameData?.currentSlide;
    final options = slide?.options ?? [];
    final isMultiple = slide?.slideType == "MULTIPLE";

    return Container(
      color: const Color(0xFF46178F),
      child: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (slide?.timeLimit ?? 1) > 0
                  ? _remainingSeconds / slide!.timeLimit
                  : 0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.cyanAccent,
              ),
            ),
            // ... (Resto de tu UI de preguntas igual que antes)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                slide?.questionText ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = _selectedOptions.contains(option.index);
                  return GestureDetector(
                    onTap: () {
                      if (isMultiple) {
                        setState(
                          () => isSelected
                              ? _selectedOptions.remove(option.index)
                              : _selectedOptions.add(option.index),
                        );
                      } else {
                        _submit(slide?.id, [option.index]);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getKahootColor(index),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option.text ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isMultiple)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _selectedOptions.isEmpty
                      ? null
                      : () => _submit(slide?.id, _selectedOptions.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("ENVIAR RESPUESTAS"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getKahootColor(int index) {
    const colors = [Colors.red, Colors.blue, Colors.orange, Colors.green];
    return colors[index % colors.length];
  }
}
