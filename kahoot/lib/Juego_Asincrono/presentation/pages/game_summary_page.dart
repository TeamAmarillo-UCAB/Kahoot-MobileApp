import 'package:flutter/material.dart';
import '../../domain/entities/game_summary.dart';
import '../utils/game_constants.dart';

class GameSummaryPage extends StatelessWidget {
  final GameSummary summary;
  const GameSummaryPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.mainPurple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Resultados",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // Trofeo
              Image.asset(
                GameAssets.iconTrophy,
                height: 150,
                errorBuilder: (_,__,___) => const Icon(Icons.emoji_events, size: 150, color: GameColors.yellow),
              ),
              
              const SizedBox(height: 40),
              
              // Tarjeta de Puntuación
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,5))]
                ),
                child: Column(
                  children: [
                    const Text("Puntaje Final", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text(
                      "${summary.totalScore}",
                      style: const TextStyle(color: Colors.black, fontSize: 48, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Estadísticas secundarias
              Row(
                children: [
                  Expanded(child: _statBox("Correctas", "${summary.correctAnswers}", Colors.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _statBox("Precisión", "${summary.accuracy.toInt()}%", Colors.blue)),
                ],
              ),
              
              const Spacer(),
              
              // Botón Salir
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: GameColors.mainPurple,
                  ),
                  onPressed: () => Navigator.of(context).pop(), // Volver al inicio
                  child: const Text("VOLVER AL INICIO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}