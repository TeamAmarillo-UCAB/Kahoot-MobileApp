import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports de Bloc
import '../bloc/live_game_bloc.dart';
import '../bloc/live_game_state.dart';

// Imports de las páginas de HOST
import 'host/host_lobby_page.dart';
import 'host/host_question_page.dart';
import 'host/host_results_page.dart';
import 'host/host_podium_page.dart';

// Imports de las páginas de PLAYER
import 'player/player_lobby_page.dart';
import 'player/player_question_page.dart';
import 'player/player_feedback_page.dart';
import 'player/player_podium_page.dart';

class LiveGamePage extends StatelessWidget {
  const LiveGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        //Si está cargando o no hay rol definido
        if (state.status == LiveGameStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //Lógica de HOST
        if (state.role == 'HOST') {
          switch (state.status) {
            case LiveGameStatus.lobby:
              return const HostLobbyView();
            case LiveGameStatus.question:
              return const HostQuestionView();
            case LiveGameStatus.results:
              return const HostResultsView();
            case LiveGameStatus.end:
              return const HostPodiumView();
            default:
              return const HostLobbyView();
          }
        }
        //Lógica de PLAYER
        else {
          switch (state.status) {
            case LiveGameStatus.lobby:
              return const PlayerLobbyView();
            case LiveGameStatus.question:
              return const PlayerQuestionPage();
            case LiveGameStatus.results:
              return const PlayerFeedbackView();
            case LiveGameStatus.end:
              return const PlayerPodiumView();
            default:
              return const PlayerLobbyView();
          }
        }
      },
    );
  }
}
