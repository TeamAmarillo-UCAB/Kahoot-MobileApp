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
import '../../../core/auth_state.dart';

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
  //TOKEN
  final token = AuthState.token.value;

  LiveGameBloc({required this.repository}) : super(LiveGameBlocState()) {
    createSessionUc = CreateLiveSession(repository);
    getPinFromQrUc = GetPinFromQr(repository);
    connectToSocketUc = ConnectToSocket(repository);
    joinLiveGameUc = JoinLiveGame(repository);
    startLiveGameUc = StartLiveGame(repository);
    nextGamePhaseUc = NextGamePhase(repository);
    submitAnswerUc = SubmitLiveAnswer(repository);

    on<InitPlayerSession>(_onInitPlayer);
    on<InitHostSession>(_onInitHost);
    on<JoinLobby>(_onJoinLobby);
    on<OnGameStateReceived>(_onGameStateUpdate);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<ScanQrCode>(_onScanQr);
    on<StartGame>(_onStartGame);
    on<NextPhase>(_onNextPhase);
  }

  Future<void> _onStartGame(
    StartGame event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    print('[BLOC] Host disparando inicio de juego...');
    try {
      startLiveGameUc.call();
    } catch (e) {
      print('[BLOC] Error al iniciar juego: $e');
    }
  }

  void _onInitPlayer(
    InitPlayerSession event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        pin: event.pin,
        role: 'PLAYER',
        status: LiveGameStatus.loading,
      ),
    );
    _gameStateSubscription?.cancel();
    _gameStateSubscription = repository.gameStateStream.listen((data) {
      add(OnGameStateReceived(data));
    });

    connectToSocketUc.call(
      pin: event.pin,
      role: 'PLAYER',
      nickname: '',
      jwt: token ?? '',
      //"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjdhYmM2ZmVkLTY2NWUtNDYzZC1iNTRkLThkNzhjMTM5N2U2ZiIsImVtYWlsIjoibmNhcmxvc0BleGFtcGxlLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY4MDI5MTAzLCJleHAiOjE3NjgwMzYzMDN9.zsatti9umbcbl7Ebr5c6ILlZ1UpjrxrtsyMWkzm5djc",
    );

    await Future.delayed(const Duration(milliseconds: 500));
    repository.sendClientReady();
    emit(state.copyWith(status: LiveGameStatus.initial));
  }

  Future<void> _onInitHost(
    InitHostSession event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LiveGameStatus.loading,
        role: 'HOST',
        errorMessage: null,
      ),
    );
    try {
      final result = await createSessionUc.call(event.kahootId);
      if (result.isSuccessful()) {
        final session = result.getValue();
        final String sessionPin = session.sessionPin.toString();

        emit(
          state.copyWith(
            status: LiveGameStatus.lobby,
            pin: sessionPin,
            session: session,
            nickname: 'Host',
          ),
        );

        _gameStateSubscription?.cancel();
        _gameStateSubscription = repository.gameStateStream.listen((data) {
          add(OnGameStateReceived(data));
        });

        connectToSocketUc.call(
          pin: sessionPin,
          role: 'HOST',
          nickname: 'Host',
          jwt: token ?? '',
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImEyNWMxMTg5LWQzYzAtNDk5MC04ZTMwLWU1ZjU2MDNjMjAyYyIsImVtYWlsIjoiYXJhdXN5dGFAY29ycmVvLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY4MDI5MDU4LCJleHAiOjE3NjgwMzYyNTh9.oUezyojXVpHKh9y3PIh0TGyPGgbF7scvEZkKRcY2mSE",
        );

        await Future.delayed(const Duration(milliseconds: 500));
        repository.sendClientReady();
      } else {
        emit(
          state.copyWith(
            status: LiveGameStatus.error,
            errorMessage: "No se pudo crear la sesión.",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LiveGameStatus.error,
          errorMessage: "Error crítico de conexión.",
        ),
      );
    }
  }

  void _onJoinLobby(JoinLobby event, Emitter<LiveGameBlocState> emit) {
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

    if (gameData.phase == 'SYNC') {
      repository.sendClientReady();
      emit(state.copyWith(status: LiveGameStatus.loading));
      return;
    }

    LiveGameStatus _mapPhaseToStatus(String phase) {
      switch (phase.toUpperCase()) {
        case 'LOBBY':
          return LiveGameStatus.lobby;
        case 'QUESTION':
          return LiveGameStatus.question;
        case 'RESULTS':
          return LiveGameStatus.results;
        case 'WAITING_RESULTS':
          return LiveGameStatus.waitingResults;
        case 'END':
          return LiveGameStatus.end;
        case 'HOST_DISCONNECTED':
          return LiveGameStatus.hostDisconnected;
        default:
          return state.status;
      }
    }

    LiveGameStatus newStatus = _mapPhaseToStatus(gameData.phase);

    if (state.status == LiveGameStatus.end &&
        newStatus == LiveGameStatus.hostDisconnected) {
      print(
        '[BLOC] Bloqueando transición a HostDisconnected porque estamos en el Podio.',
      );
      return;
    }

    final mergedGameData = gameData.copyWith(
      currentSlide: gameData.currentSlide ?? state.gameData?.currentSlide,

      totalScore: (gameData.totalScore == null || gameData.totalScore == 0)
          ? state.gameData?.totalScore
          : gameData.totalScore,
      rank: (gameData.rank == null || gameData.rank == 0)
          ? state.gameData?.rank
          : gameData.rank,
      streak: (gameData.streak == null || gameData.streak == 0)
          ? state.gameData?.streak
          : gameData.streak,
    );

    emit(state.copyWith(status: newStatus, gameData: mergedGameData));
  }

  @override
  Future<void> close() {
    _gameStateSubscription?.cancel();
    repository.disconnect();
    return super.close();
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    emit(state.copyWith(status: LiveGameStatus.waitingResults));
    repository.submitAnswer(
      questionId: event.questionId,
      answerIds: event.answerIds,
      timeElapsedMs: event.timeElapsedMs,
    );
  }

  Future<void> _onScanQr(
    ScanQrCode event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    emit(state.copyWith(status: LiveGameStatus.loading, errorMessage: null));

    try {
      final result = await getPinFromQrUc.call(event.qrToken);

      if (result.isSuccessful()) {
        final session = result.getValue();
        final String pinObtenido = session['sessionPin'].toString();

        emit(state.copyWith(pin: pinObtenido));

        add(InitPlayerSession(pinObtenido));
      } else {
        print("Error al validar QR: ${result.getError()}");

        emit(
          state.copyWith(
            status: LiveGameStatus.error,
            errorMessage: "El QR ha expirado o ya no es válido",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LiveGameStatus.error,
          errorMessage: "Error de conexión al escanear",
        ),
      );
    }
  }

  void _onNextPhase(NextPhase event, Emitter<LiveGameBlocState> emit) {
    print('[BLOC] Solicitando siguiente fase al servidor...');
    nextGamePhaseUc.call();
  }
}
