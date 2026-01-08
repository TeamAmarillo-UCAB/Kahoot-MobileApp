import 'package:flutter/material.dart';
import '../../bloc/live_game_state.dart';

class PlayerPodiumView extends StatelessWidget {
  final LiveGameBlocState state;
  const PlayerPodiumView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final rank = data?.rank ?? 0;
    final isWinner = rank == 1;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF46178F), Color(0xFF250855)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de Trofeo o Medalla
            Icon(
              isWinner ? Icons.emoji_events : Icons.stars,
              size: 120,
              color: isWinner ? Colors.amber : Colors.white70,
            ),
            const SizedBox(height: 20),
            Text(
              isWinner ? "¡ERES EL GANADOR!" : "¡BUEN TRABAJO!",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tu puesto final: #$rank",
              style: const TextStyle(color: Colors.white70, fontSize: 24),
            ),
            const SizedBox(height: 30),

            // Tarjeta de estadísticas finales
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _StatRow(
                    label: "Puntaje Total",
                    value: "${data?.totalScore ?? 0}",
                  ),
                  const Divider(color: Colors.white24),
                  _StatRow(
                    label: "Racha Final",
                    value: "${data?.lastPointsEarned ?? 0}",
                  ), // O usa streak si lo tienes
                ],
              ),
            ),

            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Cerramos todo y volvemos a la pantalla principal de la app
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF46178F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "SALIR AL INICIO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
