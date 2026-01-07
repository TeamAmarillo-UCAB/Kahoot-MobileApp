import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../../infrastructure/datasource/live_game_datasource_impl.dart';
import '../../../infrastructure/repositories/live_game_repository_impl.dart';
import '../../../application/usecases/connect_to_socket.dart';
import '../../../application/usecases/create_live_session.dart';
import '../../../application/usecases/get_pin_from_qr.dart';
import '../../../application/usecases/join_live_game.dart';
import '../../../application/usecases/next_game_phase.dart';
import '../../../application/usecases/start_live_game.dart';
import '../../../application/usecases/submit_live_answer.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';
import 'qr_scanner_page.dart';
import 'nickname_entry_page.dart';

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({Key? key}) : super(key: key);

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  late final LiveGameBloc _liveGameBloc;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final dio = Dio(
      BaseOptions(baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api'),
    );
    final datasource = LiveGameDatasourceImpl(dio: dio);
    final repository = LiveGameRepositoryImpl(datasource: datasource);

    _liveGameBloc = LiveGameBloc(
      createSessionUc: CreateLiveSession(repository),
      getPinFromQrUc: GetPinFromQr(repository),
      connectToSocketUc: ConnectToSocket(repository),
      joinLiveGameUc: JoinLiveGame(repository),
      startLiveGameUc: StartLiveGame(repository),
      nextGamePhaseUc: NextGamePhase(repository),
      submitAnswerUc: SubmitLiveAnswer(repository),
      repository: repository,
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _liveGameBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _liveGameBloc,
      child: BlocListener<LiveGameBloc, LiveGameBlocState>(
        listener: (context, state) {
          // Si tenemos un PIN (venga de QR o Manual), pasamos al Nickname
          if (state.pin != null && state.status == LiveGameStatus.initial) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NicknameEntryPage(pin: state.pin!),
              ),
            );
          }
          if (state.status == LiveGameStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF222222),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFD54F),
            title: const Text(
              'Unirse al Juego',
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _pinController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  decoration: const InputDecoration(
                    hintText: 'PIN DEL JUEGO',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_pinController.text.isNotEmpty) {
                      _liveGameBloc.add(InitPlayerSession(_pinController.text));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                  ),
                  child: const Text(
                    'INGRESAR',
                    style: TextStyle(color: Colors.brown),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final String? token = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QrScannerPage()),
                    );
                    if (token != null) _liveGameBloc.add(ScanQrCode(token));
                  },
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFFFFD54F),
                  ),
                  label: const Text(
                    'Escanear QR',
                    style: TextStyle(color: Color(0xFFFFD54F)),
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
