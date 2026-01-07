import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/live_game_state.dart';
import '../../domain/entities/live_session.dart';
import '../../domain/repositories/live_game_repository.dart';
import '../../application/usecases/connect_to_socket.dart';
import '../../application/usecases/create_live_session.dart';
import '../../application/usecases/get_pin_from_qr.dart';
import '../../application/usecases/join_live_game.dart';
import '../../application/usecases/next_game_phase.dart';
import '../../application/usecases/start_live_game.dart';
import '../../application/usecases/submit_live_answer.dart';
import 'live_game_event.dart';
import 'live_game_state.dart';

class LiveGameBloc extends Bloc<LiveGameEvent, LiveGameBlocState> {
  final CreateLiveSession createSessionUc;
  final GetPinFromQr getPinFromQrUc;
  final ConnectToSocket connectToSocketUc;
  final JoinLiveGame joinLiveGameUc;
  final StartLiveGame startLiveGameUc;
  final NextGamePhase nextGamePhaseUc;
  final SubmitLiveAnswer submitAnswerUc;
  final LiveGameRepository repository;

  StreamSubscription? _gameStateSubscription;

  LiveGameBloc({
    required this.createSessionUc,
    required this.getPinFromQrUc,
    required this.connectToSocketUc,
    required this.joinLiveGameUc,
    required this.startLiveGameUc,
    required this.nextGamePhaseUc,
    required this.submitAnswerUc,
    required this.repository,
  }) : super(LiveGameBlocState()) {
    on<InitHostSession>(_onInitHost);
    on<ScanQrCode>(_onScanQr);
    on<JoinLobby>(_onJoinLobby);
    on<StartGame>((event, emit) => startLiveGameUc.call());
    on<NextPhase>((event, emit) => nextGamePhaseUc.call());
    on<SubmitAnswer>(_onSubmitAnswer);
    on<OnGameStateReceived>(_onGameStateUpdate);
  }

  // --- MANEJADORES DE EVENTOS ---

  // 1. En el método _onInitHost
  Future<void> _onInitHost(
    InitHostSession event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    emit(state.copyWith(status: LiveGameStatus.loading));
    final result = await createSessionUc.call(event.kahootId);

    if (result.isSuccessful()) {
      // 1. Forzar trato como dynamic
      final dynamic rawValue = result.getValue();

      // 2. Verificar y lo convertir
      final LiveSession session = (rawValue is Map<String, dynamic>)
          ? LiveSession.fromJson(rawValue)
          : rawValue as LiveSession;

      _startSocketConnection(session.sessionPin, 'HOST', 'Admin');

      emit(
        state.copyWith(
          status: LiveGameStatus.lobby,
          session: session,
          role: 'HOST',
          pin: session.sessionPin,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: LiveGameStatus.error,
          errorMessage: "Error al crear sesión",
        ),
      );
    }
  }

  Future<void> _onScanQr(
    ScanQrCode event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    emit(state.copyWith(status: LiveGameStatus.loading));
    final result = await getPinFromQrUc.call(event.qrToken);

    if (result.isSuccessful()) {
      // Casting Seguro
      final dynamic rawValue = result.getValue();

      final LiveSession session = (rawValue is Map<String, dynamic>)
          ? LiveSession.fromJson(rawValue)
          : rawValue as LiveSession;

      emit(
        state.copyWith(
          session: session,
          pin: session.sessionPin,
          role: 'PLAYER',
          status: LiveGameStatus.initial,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: LiveGameStatus.error,
          errorMessage: "QR no válido",
        ),
      );
    }
  }

  void _onJoinLobby(JoinLobby event, Emitter<LiveGameBlocState> emit) {
    if (state.pin == null) return;

    _startSocketConnection(state.pin!, 'PLAYER', event.nickname);
    joinLiveGameUc.call(event.nickname);
  }

  void _onSubmitAnswer(SubmitAnswer event, Emitter<LiveGameBlocState> emit) {
    submitAnswerUc.call(
      questionId: event.questionId,
      answerIds: event.answerIds,
      timeElapsedMs: event.timeElapsedMs,
    );
  }

  // --- LÓGICA DE STREAM Y SOCKET ---

  void _startSocketConnection(String pin, String role, String nickname) {
    // 1. Conexión física
    connectToSocketUc.call(
      pin: pin,
      role: role,
      nickname: nickname,
      jwt: 'TOKEN_AQUÍ', //ACÁ VA EL TOKENNNNNN
    );

    // 2. Suscripción al flujo de eventos del servidor
    _gameStateSubscription?.cancel();
    _gameStateSubscription = repository.gameStateStream.listen((data) {
      add(OnGameStateReceived(data));
    });

    // 3. Handshake lógico para pedir el estado actual
    repository.sendClientReady();
  }

  void _onGameStateUpdate(
    OnGameStateReceived event,
    Emitter<LiveGameBlocState> emit,
  ) {
    final LiveGameState gameData = event.gameState;

    LiveGameStatus newStatus = state.status;

    // Mapeo de fases del backend a estados de la UI
    switch (gameData.phase) {
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
        newStatus = LiveGameStatus.podium;
        break;
    }

    emit(state.copyWith(status: newStatus, gameData: gameData));
  }

  @override
  Future<void> close() {
    _gameStateSubscription?.cancel();
    repository.disconnect();
    return super.close();
  }
}
