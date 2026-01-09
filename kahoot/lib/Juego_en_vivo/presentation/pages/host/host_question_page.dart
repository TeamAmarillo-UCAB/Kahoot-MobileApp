import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_state.dart';

class HostQuestionView extends StatefulWidget {
  const HostQuestionView({super.key});

  @override
  State<HostQuestionView> createState() => _HostQuestionViewState();
}

class _HostQuestionViewState extends State<HostQuestionView> {
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    // Inicializar el tiempo desde el estado actual del BLoC
    final state = context.read<LiveGameBloc>().state;
    _secondsRemaining = state.gameData?.currentSlide?.timeLimit ?? 30;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        final slide = state.gameData?.currentSlide;
        final String questionText = slide?.questionText ?? 'Cargando...';
        final int currentIdx = (slide?.questionIndex ?? 0) + 1;
        final String? imageUrl = slide?.imageUrl;

        return Scaffold(
          backgroundColor: const Color(
            0xFF46178F,
          ), // Fondo morado igual al lobby
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // 4) Simplificado: Solo "Pregunta X"
                Text(
                  'Pregunta $currentIdx',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 2) Ajuste de imagen mejorado
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white10,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              imageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.image,
                                    color: Colors.white24,
                                    size: 50,
                                  ),
                            ),
                          ),
                        Text(
                          questionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // 3) Timer que se mueve
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                value:
                                    _secondsRemaining /
                                    (slide?.timeLimit ?? 30),
                                strokeWidth: 8,
                                color: Colors.white,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            Text(
                              '$_secondsRemaining',
                              style: const TextStyle(
                                color: Colors.white,
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
                // Grid de opciones visual para el Host
                Container(
                  padding: const EdgeInsets.all(16),
                  height: 180,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: slide?.options.length ?? 0,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: _getOptionColor(index),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          slide!.options[index].text ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
    return [Colors.red, Colors.blue, Colors.orange, Colors.green][index % 4];
  }
}
