import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_state.dart';

class HostPodiumView extends StatelessWidget {
  const HostPodiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        final winners = state.gameData?.leaderboard ?? [];

        return Scaffold(
          backgroundColor: Colors.indigo[900],
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
                // Mostrar el Top 3
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: winners
                        .take(3)
                        .map(
                          (player) => Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: const Icon(
                                Icons.stars,
                                color: Colors.amber,
                              ),
                              title: Text(
                                player.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text('${player.score} pts'),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('VOLVER AL INICIO'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
