import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';
import '../../widgets/live_timer_widget.dart';

class PlayerQuestionView extends StatefulWidget {
  final LiveGameBlocState state;
  const PlayerQuestionView({super.key, required this.state});

  @override
  State<PlayerQuestionView> createState() => _PlayerQuestionViewState();
}

class _PlayerQuestionViewState extends State<PlayerQuestionView> {
  late Stopwatch _stopwatch;
  final Set<String> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
  }

  @override
  void dispose() {
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Espera al anfitrión...",
                style: TextStyle(color: Colors.white70, fontSize: 18),
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
            // TIMER CON EL NÚMERO DINÁMICO
            LiveTimerWidget(
              timeLimitSeconds: slide?.timeLimit ?? 30,
              onTimerFinished: () {
                if (isMultiple && _selectedOptions.isNotEmpty) {
                  _submit(slide?.id, _selectedOptions.toList());
                }
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                slide?.questionText ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (slide?.imageUrl != null && slide!.imageUrl!.isNotEmpty)
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(slide.imageUrl!, fit: BoxFit.contain),
                ),
              ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _getKahootColor(index),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 6)
                            : Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (option.mediaUrl != null &&
                                option.mediaUrl!.isNotEmpty)
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    option.mediaUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 5),
                            Text(
                              option.text ?? "",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (isMultiple)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _selectedOptions.isEmpty
                      ? null
                      : () => _submit(slide?.id, _selectedOptions.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[700],
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "ENVIAR RESPUESTAS",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getKahootColor(int index) {
    const colors = [
      Color(0xFFE21B3C),
      Color(0xFF1368CE),
      Color(0xFFD89E00),
      Color(0xFF26890C),
    ];
    return colors[index % colors.length];
  }
}
