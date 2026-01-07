import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Resultados de la Ronda'),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Tabla de Posiciones',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: leaderboard.isEmpty
                    ? const Center(child: Text("Calculando resultados..."))
                    : ListView.builder(
                        itemCount: leaderboard.length,
                        itemBuilder: (context, index) {
                          final player = leaderboard[index];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(player.name),
                            trailing: Text(
                              '${player.score} pts',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.indigo,
                  ),
                  onPressed: () =>
                      context.read<LiveGameBloc>().add(NextPhase()),
                  child: const Text(
                    'SIGUIENTE PREGUNTA',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
