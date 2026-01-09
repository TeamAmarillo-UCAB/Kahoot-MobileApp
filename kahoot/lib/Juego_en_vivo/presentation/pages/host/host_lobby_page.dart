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
      BaseOptions(baseUrl: 'https://quizzy-backend-0wh2.onrender.com'),
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
                      //Players es una lista de Strings o objetos con nickname
                      final player = players[index];
                      return ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: Text(
                          player.toString(), // Ajusta a string
                          style: const TextStyle(color: Colors.white),
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
