import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

// Infraestructura
import '../../../infrastructure/repositories/live_game_repository_impl.dart';
import '../../../infrastructure/datasource/live_game_datasource_impl.dart';

// BLoC y pantallas
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';

class HostLobbyView extends StatefulWidget {
  final String kahootId;

  const HostLobbyView({Key? key, required this.kahootId}) : super(key: key);

  @override
  State<HostLobbyView> createState() => _HostLobbyViewState();
}

class _HostLobbyViewState extends State<HostLobbyView> {
  late final LiveGameBloc _bloc;

  @override
  void initState() {
    super.initState();

    //Configuración de Dio
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjdhYmM2ZmVkLTY2NWUtNDYzZC1iNTRkLThkNzhjMTM5N2U2ZiIsImVtYWlsIjoibmNhcmxvc0BleGFtcGxlLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY3OTU4OTIxLCJleHAiOjE3Njc5NjYxMjF9.hcWKnnA9pIqHUGzIP-7-He0ydO2ZpYzFDdRxp3AAv30',
          'Content-Type': 'application/json',
        },
      ),
    );

    //Inyección de Infraestructura
    final datasource = LiveGameDatasourceImpl(dio: dio);
    final repository = LiveGameRepositoryImpl(datasource: datasource);

    //Inicializar BLoC
    _bloc = LiveGameBloc(repository: repository);

    //Disparar evento inicial para crear/unirse a la sesión como Host
    _bloc.add(InitHostSession(widget.kahootId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF46178F),
        appBar: AppBar(
          title: const Text('Lobby del Host'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<LiveGameBloc, LiveGameBlocState>(
          builder: (context, state) {
            //Acceder a gameData con información de la sesión
            final gameData = state.gameData;
            final players = gameData?.players ?? []; // Jugadores

            //Si aún está cargando o no hay PIN
            if (state.status == LiveGameStatus.loading || state.pin == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'PIN DE JUEGO:',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                Text(
                  state.pin!, // El PIN viene del estado principal del Bloc
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Jugadores conectados: ${players.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];

                      // ¡IMPORTANTE!: Agregar el 'return' para que el widget se renderice
                      return Card(
                        color: Colors.white.withOpacity(
                          0.1,
                        ), // Fondo semitransparente
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Color(0xFF46178F)),
                          ),
                          title: Text(
                            player['nickname'] ?? 'Anónimo',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .white, // Texto en blanco para que se vea sobre el morado
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    //Evento StartGame que ya definido
                    onPressed: players.isEmpty
                        ? null
                        : () => context.read<LiveGameBloc>().add(StartGame()),
                    child: const Text('EMPEZAR JUEGO'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
