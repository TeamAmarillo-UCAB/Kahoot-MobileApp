import 'package:flutter/material.dart';
import '../../domain/entities/game_summary.dart';
import '../utils/game_constants.dart';

class GameSummaryPage extends StatelessWidget {
  final GameSummary summary;
  const GameSummaryPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Usamos los colores definidos en GameColors
            colors: [Color(0xFF46178F), GameColors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Podrías usar GameAssets.iconTrophy si es una imagen,
              // o el Icon con colores de la paleta
              const Icon(
                Icons.emoji_events,
                color: GameColors.yellow,
                size: 140,
              ),
              const SizedBox(height: 20),
              const Text(
                "¡PARTIDA FINALIZADA!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              // Tarjeta de Puntaje Total
              _buildStatCard(
                label: "Puntaje Total",
                value: summary.totalScore.toString(),
                isPrimary: true,
                color: Colors.white,
              ),

              const SizedBox(height: 20),

              // Fila de estadísticas secundarias
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatCard(
                    label: "Correctas",
                    value: "${summary.correctAnswers}",
                    isPrimary: false,
                    color: GameColors.correctGreen,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    label: "Precisión",
                    value: "${(summary.accuracy * 100).toInt()}%",
                    isPrimary: false,
                    color: GameColors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Botón de Salida estilizado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF46178F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "VOLVER AL INICIO",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required bool isPrimary,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPrimary ? 50 : 30,
        vertical: isPrimary ? 25 : 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isPrimary ? 55 : 30,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
