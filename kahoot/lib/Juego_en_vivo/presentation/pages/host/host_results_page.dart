import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kahoot/Juego_en_vivo/presentation/widgets/game_background.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';

class HostResultsView extends StatelessWidget {
  const HostResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        final leaderboard = state.gameData?.leaderboard ?? [];
        final stats = state.gameData?.stats ?? {};
        final distribution =
            stats['distribution'] as Map<String, dynamic>? ?? {};
        final totalAnswers = stats['totalAnswers'] ?? 0;
        final isLast = state.gameData?.progress?['isLastSlide'] ?? false;
        final dynamicUrl = state.session?.themeUrl;

        return Scaffold(
          body: Stack(
            children: [
              GameBackground(imageUrl: dynamicUrl),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'RESULTADOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Container(
                      height: 180,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(4, (i) {
                          final count = distribution[i.toString()] ?? 0;
                          final double percentage = totalAnswers > 0
                              ? (count / totalAnswers)
                              : 0;
                          return _buildBar(i, count, percentage);
                        }),
                      ),
                    ),

                    const Text(
                      'TOP JUGADORES',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: leaderboard.length,
                        itemBuilder: (context, index) {
                          final player = leaderboard[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: index == 0
                                    ? Colors.amber
                                    : Colors.white24,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: index == 0
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                player['nickname'] ?? 'Jugador',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                '${player['score']} pts',
                                style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<LiveGameBloc>().add(NextPhase());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF46178F),
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          isLast ? "VER PODIO FINAL" : "SIGUIENTE PREGUNTA",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(int index, dynamic count, double percentage) {
    final colors = [
      const Color(0xFFE21B3C),
      const Color(0xFF1368CE),
      const Color(0xFFD89E00),
      const Color(0xFF26890C),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 45,
          height: (percentage * 100) + 10,
          decoration: BoxDecoration(
            color: colors[index % 4],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
      ],
    );
  }
}
