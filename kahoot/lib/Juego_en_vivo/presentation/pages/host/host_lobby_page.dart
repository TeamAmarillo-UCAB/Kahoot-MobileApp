import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../infrastructure/repositories/live_game_repository_impl.dart';
import '../../../infrastructure/datasource/live_game_datasource_impl.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';
import 'host_question_page.dart';
import 'host_results_page.dart';
import 'host_podium_page.dart';

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
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api',
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjdhYmM2ZmVkLTY2NWUtNDYzZC1iNTRkLThkNzhjMTM5N2U2ZiIsImVtYWlsIjoibmNhcmxvc0BleGFtcGxlLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY4MDE1Mjg5LCJleHAiOjE3NjgwMjI0ODl9.WnnDmzWHrTDc-LnAv0DaLX6OIUC4RbPVQi5DoAoM-SM',
          'Content-Type': 'application/json',
        },
      ),
    );

    final datasource = LiveGameDatasourceImpl(dio: dio);
    final repository = LiveGameRepositoryImpl(datasource: datasource);
    _bloc = LiveGameBloc(repository: repository);
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
        body: BlocBuilder<LiveGameBloc, LiveGameBlocState>(
          builder: (context, state) {
            // TRANSICIÓN: Si el estado cambia a question, muestra la vista de la pregunta
            if (state.status == LiveGameStatus.question) {
              return const HostQuestionView();
            }
            if (state.status == LiveGameStatus.results) {
              // Verificar si es la última pregunta
              final isLast = state.gameData?.progress?['isLastSlide'] ?? false;

              if (isLast) {
                return const HostPodiumView(); // Si es la última, mostramos podio directamente
              } else {
                return const HostResultsView(); // Si no, mostramos la tabla de posiciones normal
              }
            }
            if (state.status == LiveGameStatus.loading || state.pin == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final players = state.gameData?.players ?? [];

            return Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'PIN DE JUEGO:',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                Text(
                  state.pin!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Jugadores: ${players.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        players[index]['nickname'] ?? 'Anónimo',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    // Al presionar, disparamos el evento al Bloc
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
