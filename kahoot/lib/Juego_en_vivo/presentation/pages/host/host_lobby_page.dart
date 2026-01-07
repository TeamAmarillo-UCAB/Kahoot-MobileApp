import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';

class HostLobbyView extends StatelessWidget {
  const HostLobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGameBloc, LiveGameBlocState>(
      builder: (context, state) {
        final players = state.gameData?.players ?? [];

        return Scaffold(
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.indigo,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Únete con este PIN:',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      Text(
                        state.pin ?? '---',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (state.session != null &&
                          state.session!.qrToken.isNotEmpty)
                        QrImageView(
                          data: state.session!.qrToken,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        )
                      else
                        const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Jugadores conectados: ${players.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: players.isEmpty
                          ? const Center(
                              child: Text("Esperando a los valientes..."),
                            )
                          : ListView.builder(
                              itemCount: players.length,
                              itemBuilder: (context, index) => Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(players[index]),
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 60),
                          backgroundColor: Colors.green,
                        ),
                        // El botón solo se activa si hay jugadores
                        onPressed: players.isEmpty
                            ? null
                            : () =>
                                  context.read<LiveGameBloc>().add(StartGame()),
                        child: const Text(
                          'EMPEZAR JUEGO',
                          style: TextStyle(fontSize: 20, color: Colors.white),
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
}
