import 'package:flutter/material.dart';
import '../../bloc/live_game_state.dart';

class PlayerLobbyView extends StatelessWidget {
  final LiveGameBlocState state;
  const PlayerLobbyView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final myNickname = state.nickname ?? "Jugador";

    return Container(
      width: double.infinity,
      color: const Color(0xFF46178F),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
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
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
