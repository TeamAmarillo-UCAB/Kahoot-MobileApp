import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_state.dart';

class HostQuestionView extends StatelessWidget {
  const HostQuestionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        // Accedemos al slide actual
        final slide = state.gameData?.currentSlide;

        // Mapeamos los campos de tu entidad LiveSlide
        final String questionText =
            slide?.questionText ?? 'Cargando pregunta...';
        final int currentIdx =
            (slide?.questionIndex ?? 0) + 1; // +1 porque suele ser base 0
        final int total = slide?.totalQuestions ?? 0;
        final int timeLimit = slide?.timeLimit ?? 0;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Pregunta $currentIdx de $total',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (slide?.imageUrl != null &&
                            slide!.imageUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Image.network(
                              slide.imageUrl!,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        Text(
                          questionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Timer visual usando timeLimit de LiveSlide
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value:
                                    1.0, // Aquí podrías animarlo si tuvieras un stream de segundos
                                strokeWidth: 8,
                                color: Colors.indigo,
                              ),
                            ),
                            Text(
                              '$timeLimit',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Grid de opciones (solo visual para el Host)
                Container(
                  padding: const EdgeInsets.all(16),
                  height: 200,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: slide?.options.length ?? 0,
                    itemBuilder: (context, index) {
                      final option = slide!.options[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: _getOptionColor(index),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          option.text ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getOptionColor(int index) {
    List<Color> colors = [Colors.red, Colors.blue, Colors.orange, Colors.green];
    return colors[index % colors.length];
  }
}
