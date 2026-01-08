import 'package:flutter/material.dart';
import '../../bloc/live_game_state.dart';

class PlayerLobbyView extends StatelessWidget {
  final LiveGameBlocState state;
  const PlayerLobbyView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final myNickname = state.nickname ?? "Jugador";
    final playersCount = state.gameData?.players?.length ?? 0;

    return Container(
      width: double.infinity,
      color: const Color(0xFF46178F),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 40),
          Text(
            '¡Estás dentro, $myNickname!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'El anfitrión iniciará el juego pronto...',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 40),
          Text(
            'Jugadores en la sala: $playersCount',
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
