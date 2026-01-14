import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/live_game_bloc.dart';
import '../bloc/live_game_state.dart';
import 'player/player_lobby_page.dart';
import 'player/player_question_page.dart';
import 'player/player_feedback_page.dart';
import 'player/player_podium_page.dart';

class LiveGamePage extends StatelessWidget {
  const LiveGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LiveGameBloc, LiveGameBlocState>(
        listener: (context, state) {
          if (state.status == LiveGameStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
        },
        child: BlocBuilder<LiveGameBloc, LiveGameBlocState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildCurrentView(state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentView(LiveGameBlocState state) {
    switch (state.status) {
      case LiveGameStatus.lobby:
        return PlayerLobbyView(key: const ValueKey('lobby'), state: state);
      case LiveGameStatus.question:
      case LiveGameStatus.waitingResults:
        return PlayerQuestionView(
          key: const ValueKey('question'),
          state: state,
        );
      case LiveGameStatus.results:
        return PlayerFeedbackView(key: const ValueKey('results'), state: state);
      case LiveGameStatus.end:
        return PlayerPodiumView(key: const ValueKey('end'), state: state);
      case LiveGameStatus.loading:
        return const Center(
          key: ValueKey('loading'),
          child: CircularProgressIndicator(),
        );
      default:
        return const Center(
          key: ValueKey('init'),
          child: Text("Esperando conexión..."),
        );
    }
  }
}
