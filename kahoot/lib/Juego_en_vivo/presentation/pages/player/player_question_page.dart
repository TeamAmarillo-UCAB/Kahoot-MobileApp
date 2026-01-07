import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart'; // Asegúrate que aquí la clase se llame LiveGameBlocState

class PlayerQuestionView extends StatefulWidget {
  const PlayerQuestionView({super.key});

  @override
  State<PlayerQuestionView> createState() => _PlayerQuestionViewState();
}

class _PlayerQuestionViewState extends State<PlayerQuestionView> {
  final Stopwatch _stopwatch = Stopwatch();
  bool _isLocallySubmitting = false;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        final data = state.gameData; // Esta es tu entidad LiveGameState
        final slide = data?.currentSlide;
        final options = slide?.options ?? [];

        // Como 'hasAnswered' no existe en tu entidad, usamos el estado local de la vista
        final bool alreadyAnswered = _isLocallySubmitting;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Pregunta ${(slide?.questionIndex ?? 0) + 1} / ${slide?.totalQuestions ?? 0}',
            ),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              const LinearProgressIndicator(),
              if (alreadyAnswered)
                const Expanded(
                  child: Center(
                    child: Text(
                      "¡Respuesta enviada!\nEspera a los demás...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 1.1,
                          ),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getOptionColor(index),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            _stopwatch.stop();
                            setState(() => _isLocallySubmitting = true);
                            context.read<LiveGameBloc>().add(
                              SubmitAnswer(
                                questionId: slide?.id ?? '',
                                answerIds: [option.index],
                                timeElapsedMs: _stopwatch.elapsedMilliseconds,
                              ),
                            );
                          },
                          child: _buildOptionContent(option),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionContent(dynamic option) {
    // CORRECCIÓN: Usamos mediaUrl (minúscula) como está en tu entidad LiveOption
    if (option.mediaUrl != null && option.mediaUrl!.isNotEmpty) {
      return Image.network(option.mediaUrl!, fit: BoxFit.contain);
    }
    return Text(
      option.text ?? '',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getOptionColor(int index) {
    const colors = [Colors.red, Colors.blue, Colors.orange, Colors.green];
    return colors[index % colors.length];
  }
}
