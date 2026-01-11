import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../infrastructure/repositories/live_game_repository_impl.dart';
import '../../../infrastructure/datasource/live_game_datasource_impl.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';
import 'host_question_page.dart';
import 'host_results_page.dart';
import 'host_podium_page.dart';
import '../../..../../../../core/auth_state.dart';

class HostLobbyView extends StatefulWidget {
  final String kahootId;
  const HostLobbyView({Key? key, required this.kahootId}) : super(key: key);

  @override
  State<HostLobbyView> createState() => _HostLobbyViewState();
}

class _HostLobbyViewState extends State<HostLobbyView> {
  late final LiveGameBloc _bloc;
  final token = AuthState.token.value;

  @override
  void initState() {
    super.initState();
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api',
        headers: {
          'Authorization': 'Bearer $token',
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
            if (state.status == LiveGameStatus.question) {
              return const HostQuestionView();
            }
            if (state.status == LiveGameStatus.results) {
              final isLast = state.gameData?.progress?['isLastSlide'] ?? false;

              if (isLast) {
                return const HostPodiumView();
              } else {
                return const HostResultsView();
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
                if (state.session?.qrToken != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: QrImageView(
                      data: state.session!.qrToken,
                      version: QrVersions.auto,
                      size: 180.0,
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
