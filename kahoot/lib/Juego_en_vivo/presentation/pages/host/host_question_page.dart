import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_state.dart';
import '../../widgets/live_timer_widget.dart';

class HostQuestionView extends StatelessWidget {
  const HostQuestionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        final slide = state.gameData?.currentSlide;
        final options = slide?.options ?? [];
        final int currentIdx = (slide?.questionIndex ?? 0) + 1;
        final String? imageUrl = slide?.imageUrl;

        return Scaffold(
          backgroundColor: const Color(0xFF46178F),
          body: SafeArea(
            child: Column(
              children: [
                // 1) TIMER ARRIBA (Reutilizando tu widget)
                LiveTimerWidget(
                  timeLimitSeconds: slide?.timeLimit ?? 30,
                  onTimerFinished: () {
                    // Opcional: El host podría recibir una alerta visual aquí
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Pregunta $currentIdx',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    slide?.questionText ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 2) AJUSTE DE IMAGEN
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Container(
                    height: 180,
                    width: double.infinity,
                    margin: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, color: Colors.white24),
                      ),
                    ),
                  ),

                // 3) GRID DE OPCIONES (Visual para el Host)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio:
                              1.5, // Un poco más achatado para el Host
                        ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: _getKahootColor(index),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          options[index].text ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 4) BOTÓN SIGUIENTE (Exclusivo del Anfitrión)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      // Aquí llamarías al evento para pasar a la siguiente fase (resultados/podio)
                      // context.read<LiveGameBloc>().add(NextPhase());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF46178F),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "SIGUIENTE",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
