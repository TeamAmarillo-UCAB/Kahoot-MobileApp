import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_state.dart';

class PlayerLobbyView extends StatelessWidget {
  const PlayerLobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        // Obtenemos el nickname del estado del BLoC, no del gameData
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
                // Opcional: Lista de otros jugadores si el server los envía
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
    );
  }
}
