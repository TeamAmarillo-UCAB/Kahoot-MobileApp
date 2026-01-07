import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../../infrastructure/datasource/live_game_datasource_impl.dart';
import '../../../infrastructure/repositories/live_game_repository_impl.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';

class NicknameEntryPage extends StatefulWidget {
  final String pin;
  const NicknameEntryPage({Key? key, required this.pin}) : super(key: key);

  @override
  State<NicknameEntryPage> createState() => _NicknameEntryPageState();
}

class _NicknameEntryPageState extends State<NicknameEntryPage> {
  late final LiveGameBloc _liveGameBloc;
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final dio = Dio(
      BaseOptions(baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api'),
    );
    final datasource = LiveGameDatasourceImpl(dio: dio);
    final repository = LiveGameRepositoryImpl(datasource: datasource);

    _liveGameBloc = LiveGameBloc(repository: repository);

    // Sincronizamos el pin en este nuevo Bloc
    _liveGameBloc.add(InitPlayerSession(widget.pin));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _liveGameBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _liveGameBloc,
      child: BlocListener<LiveGameBloc, LiveGameBlocState>(
        listener: (context, state) {
          if (state.status == LiveGameStatus.lobby) {
            // Aquí iría el Navigator a la página de espera del Lobby
            print("Conectado exitosamente al Lobby");
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF222222),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFD54F),
            title: Text('PIN: ${widget.pin}'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _nicknameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'NICKNAME',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_nicknameController.text.isNotEmpty) {
                      _liveGameBloc.add(JoinLobby(_nicknameController.text));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                  ),
                  child: const Text(
                    '¡LISTO!',
                    style: TextStyle(color: Colors.brown),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
