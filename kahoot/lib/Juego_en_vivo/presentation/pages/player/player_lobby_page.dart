// lib/presentation/pages/player/player_lobby_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_state.dart';
import 'player_question_page.dart'; // Asegúrate de importar la página

class PlayerLobbyView extends StatelessWidget {
  const PlayerLobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos BlocListener para efectos secundarios (Navegación)
    return BlocListener<LiveGameBloc, LiveGameBlocState>(
      listener: (context, state) {
        if (state.status == LiveGameStatus.question) {
          print("🚀 ¡Estado QUESTION detectado! Navegando...");

          final liveGameBloc = context.read<LiveGameBloc>();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: liveGameBloc,
                child: const PlayerQuestionPage(),
              ),
            ),
          );
        }

        // Bonus: Si el host se va, volver al inicio
        if (state.status == LiveGameStatus.initial ||
            state.gameData?.phase == 'END') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El anfitrión ha finalizado la sesión'),
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: BlocBuilder<LiveGameBloc, LiveGameBlocState>(
        builder: (context, state) {
          final myNickname = state.nickname ?? "Jugador";
          final playersCount = state.gameData?.players?.length ?? 0;

          return Scaffold(
            backgroundColor: const Color(0xFF46178F),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 40),
                  Text(
                    '¡Estás dentro, $myNickname!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'El anfitrión iniciará el juego pronto...',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  if (playersCount > 0)
                    Text(
                      'Otros jugadores en la sala: $playersCount',
                      style: const TextStyle(color: Colors.white54),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
