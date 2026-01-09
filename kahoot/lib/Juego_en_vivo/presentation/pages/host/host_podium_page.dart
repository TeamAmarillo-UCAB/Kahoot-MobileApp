import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';

class HostPodiumView extends StatelessWidget {
  const HostPodiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        // SOLUCIÓN AL ERROR:
        // 1. Usamos ?? [] para que si todo falla, sea una lista vacía y no de crash.
        // 2. Intentamos sacar los datos de 'podiumData' (fase final).
        // 3. Si no hay nada, buscamos en 'leaderboard' (fase de salto desde resultados).
        final List winners =
            state.gameData?.podiumData ?? state.gameData?.leaderboard ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 120, color: Colors.amber),
                const SizedBox(height: 20),
                const Text(
                  '¡PODIO FINAL!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Lista de ganadores (Top 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    // Agregamos una verificación extra para no intentar hacer .take si la lista es nula
                    children: winners.take(3).map((player) {
                      // Usamos dynamic o Map para acceder a las keys de forma segura
                      final name =
                          player['nickname'] ?? player['name'] ?? 'Jugador';
                      final score = player['score'] ?? 0;

                      return Card(
                        color: Colors.white.withOpacity(0.1),
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.stars, color: Colors.amber),
                          title: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            '$score pts',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 60),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      // Al presionar aquí, el Bloc enviará el último next_phase al servidor
                      context.read<LiveGameBloc>().add(NextPhase());
                      // Y cerramos la pantalla volviendo al inicio
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'VOLVER AL INICIO',
                      style: TextStyle(
                        fontSize: 18,
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
}
