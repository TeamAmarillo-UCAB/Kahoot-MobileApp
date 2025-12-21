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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(GameAssets.bgBlue),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(GameAssets.iconTrophy, width: 120),
              const SizedBox(height: 20),
              Text(
                "Puntaje Final",
                style: const TextStyle(color: Colors.white, fontSize: 32),
              ),
              Text(
                summary.totalScore.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
