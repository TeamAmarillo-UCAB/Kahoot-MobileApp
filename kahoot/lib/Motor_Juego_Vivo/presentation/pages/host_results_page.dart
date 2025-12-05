import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/scoreboard_widget.dart';

class HostResultsPage extends StatelessWidget {
  const HostResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host - Resultados')),
      body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
        final state = context.select((GameBloc bloc) => bloc.state);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isResults) {
            if (state.isQuestion) Navigator.of(context).pushReplacementNamed('/host_question');
            if (state.isEnd) Navigator.of(context).pushReplacementNamed('/host_podium');
          }
        });

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              if (state.gameState.correctAnswerId != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Correct: ${state.gameState.correctAnswerId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              Expanded(child: ScoreboardWidget(entries: state.gameState.scoreboard)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : () => context.read<GameBloc>().add(GameEventHostNextPhase()),
                  child: state.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Siguiente'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
