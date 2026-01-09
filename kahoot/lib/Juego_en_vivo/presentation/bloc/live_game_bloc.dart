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
    on<InitHostSession>(_onInitHost);
    on<JoinLobby>(_onJoinLobby);
    on<OnGameStateReceived>(_onGameStateUpdate);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<ScanQrCode>(_onScanQr);
    on<StartGame>(_onStartGame); // NUEVO EVENTO PARA EL HOST
  }

  // Manejador para que el Host inicie el juego
  Future<void> _onStartGame(
    StartGame event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    print('[BLOC] Host disparando inicio de juego...');
    try {
      startLiveGameUc.call();
      // No emitimos estado aquí, esperamos que el socket responda con "question_started"
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
      jwt: "20936913-0c59-4ee4-ad35-634ef24d7d3d",
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
          jwt: "7abc6fed-665e-463d-b54d-8d78c1397e6f",
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
    emit(state.copyWith(status: LiveGameStatus.loading));
    final result = await getPinFromQrUc.call(event.qrToken);
    if (result.isSuccessful()) {
      final session = result.getValue();
      add(InitPlayerSession(session['sessionPin'].toString()));
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
