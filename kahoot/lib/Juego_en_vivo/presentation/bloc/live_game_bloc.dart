import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/live_game_repository.dart';
import '../../application/usecases/connect_to_socket.dart';
import '../../application/usecases/join_live_game.dart';
import '../../application/usecases/get_pin_from_qr.dart';
import '../../application/usecases/create_live_session.dart';
import '../../application/usecases/start_live_game.dart';
import '../../application/usecases/next_game_phase.dart';
import '../../application/usecases/submit_live_answer.dart';
import 'live_game_event.dart';
import 'live_game_state.dart';

class LiveGameBloc extends Bloc<LiveGameEvent, LiveGameBlocState> {
  final LiveGameRepository repository;

  late final CreateLiveSession createSessionUc;
  late final GetPinFromQr getPinFromQrUc;
  late final ConnectToSocket connectToSocketUc;
  late final JoinLiveGame joinLiveGameUc;
  late final StartLiveGame startLiveGameUc;
  late final NextGamePhase nextGamePhaseUc;
  late final SubmitLiveAnswer submitAnswerUc;

  StreamSubscription? _gameStateSubscription;

  LiveGameBloc({required this.repository}) : super(LiveGameBlocState()) {
    createSessionUc = CreateLiveSession(repository);
    getPinFromQrUc = GetPinFromQr(repository);
    connectToSocketUc = ConnectToSocket(repository);
    joinLiveGameUc = JoinLiveGame(repository);
    startLiveGameUc = StartLiveGame(repository);
    nextGamePhaseUc = NextGamePhase(repository);
    submitAnswerUc = SubmitLiveAnswer(repository);

    on<InitPlayerSession>(_onInitPlayer);
    on<JoinLobby>(_onJoinLobby);
    on<OnGameStateReceived>(_onGameStateUpdate);
    on<ScanQrCode>(_onScanQr);
  }

  void _onInitPlayer(
    InitPlayerSession event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    print('🚀 [BLOC] Paso 1: Iniciando Handshake para PIN: ${event.pin}');

    emit(
      state.copyWith(
        pin: event.pin,
        role: 'PLAYER',
        status: LiveGameStatus.loading,
      ),
    );

    // 1. Suscribir el stream ANTES de conectar para no perder el primer evento
    print('📡 [BLOC] Suscribiendo al stream de estados...');
    _gameStateSubscription?.cancel();
    _gameStateSubscription = repository.gameStateStream.listen((data) {
      print('💡 [BLOC] Stream notificó nuevo estado: ${data.phase}');
      add(OnGameStateReceived(data));
    }, onError: (err) => print('🚨 [BLOC] Error en Stream: $err'));

    // 2. Ejecutar Conexión (Handshake)
    connectToSocketUc.call(
      pin: event.pin,
      role: 'PLAYER',
      nickname: 'Carlios',
      jwt: "20936913-0c59-4ee4-ad35-634ef24d7d3d",
    );

    // 3. Sincronización lógica
    // Le damos 500ms para que el túnel TCP/WS se estabilice antes de pedir sync
    await Future.delayed(const Duration(milliseconds: 500));
    print('📢 [BLOC] Enviando client_ready...');
    repository.sendClientReady();

    emit(state.copyWith(status: LiveGameStatus.initial));
  }

  void _onJoinLobby(JoinLobby event, Emitter<LiveGameBlocState> emit) {
    print(
      '👤 [BLOC] Guardando nickname y enviando player_join: ${event.nickname}',
    );

    // Guardamos el nickname en el estado local antes de enviarlo
    emit(
      state.copyWith(status: LiveGameStatus.loading, nickname: event.nickname),
    );

    joinLiveGameUc.call(event.nickname);
  }

  void _onGameStateUpdate(
    OnGameStateReceived event,
    Emitter<LiveGameBlocState> emit,
  ) {
    final gameData = event.gameState;
    print('🔄 [BLOC] Actualizando UI a fase: ${gameData.phase}');

    LiveGameStatus newStatus = state.status;
    switch (gameData.phase.toUpperCase()) {
      case 'LOBBY':
        newStatus = LiveGameStatus.lobby;
        break;
      case 'QUESTION':
        newStatus = LiveGameStatus.question;
        break;
      case 'RESULTS':
        newStatus = LiveGameStatus.results;
        break;
      case 'PODIUM':
      case 'END':
        newStatus = LiveGameStatus.end;
        break;
    }

    emit(state.copyWith(status: newStatus, gameData: gameData));
  }

  @override
  Future<void> close() {
    print('🛑 [BLOC] Cerrando BLoC y liberando recursos');
    _gameStateSubscription?.cancel();
    repository.disconnect();
    return super.close();
  }

  Future<void> _onScanQr(
    ScanQrCode event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    emit(state.copyWith(status: LiveGameStatus.loading));
    final result = await getPinFromQrUc.call(event.qrToken);
    if (result.isSuccessful()) {
      final session = result.getValue();
      final pin = session['sessionPin'].toString();
      add(InitPlayerSession(pin));
    } else {
      emit(
        state.copyWith(
          status: LiveGameStatus.error,
          errorMessage: "QR inválido",
        ),
      );
    }
  }
}
