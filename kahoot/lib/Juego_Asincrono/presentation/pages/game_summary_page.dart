import 'package:flutter/material.dart';
import '../../domain/entities/game_summary.dart';
import '../utils/game_constants.dart';

class GameSummaryPage extends StatelessWidget {
  final GameSummary summary;
  const GameSummaryPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Resultados",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Trofeo
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Image.asset(
                  GameAssets.iconTrophy,
                  height: 180,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.emoji_events,
                    size: 150,
                    color: GameColors.yellow,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Tarjeta de Puntuación
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: GameColors.amberTheme,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Puntaje Final",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${summary.totalScore}",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Estadísticas
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      "Correctas",
                      "${summary.correctAnswers}",
                      GameColors.green,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _statBox(
                      "Precisión",
                      "${summary.accuracy.toInt()}%",
                      GameColors.blue,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Botón Salir
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameColors.amberTheme,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "VOLVER AL INICIO",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Colors.black87,
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

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
