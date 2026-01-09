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
  }

  void _onInitPlayer(
    InitPlayerSession event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    print('[BLOC] Paso 1: Iniciando Handshake para PIN: ${event.pin}');

    emit(
      state.copyWith(
        pin: event.pin,
        role: 'PLAYER',
        status: LiveGameStatus.loading,
      ),
    );

    //Suscribir stream
    print('[BLOC] Suscribiendo al stream de estados...');
    _gameStateSubscription?.cancel();
    _gameStateSubscription = repository.gameStateStream.listen((data) {
      print('[BLOC] Stream notificó nuevo estado: ${data.phase}');
      add(OnGameStateReceived(data));
    }, onError: (err) => print('[BLOC] Error en Stream: $err'));

    //Handshake CAMBIAR CUANDO ESTÉ EL JWT AAAAA
    connectToSocketUc.call(
      pin: event.pin,
      role: 'PLAYER',
      nickname: '',
      jwt: "20936913-0c59-4ee4-ad35-634ef24d7d3d",
    );

    //Sincronización lógica
    //500ms para que el túnel TCP/WS se estabilice antes de pedir sync
    await Future.delayed(const Duration(milliseconds: 500));
    print('[BLOC] Enviando client_ready...');
    repository.sendClientReady();

    emit(state.copyWith(status: LiveGameStatus.initial));
  }

  Future<void> _onInitHost(
    InitHostSession event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    print(
      '[DEBUG-BLOC] Paso 1 Host: Iniciando creación de sesión para Kahoot ID: ${event.kahootId}',
    );

    // 1. Iniciamos estado de carga
    emit(
      state.copyWith(
        status: LiveGameStatus.loading,
        role: 'HOST',
        errorMessage: null, // Limpiamos errores previos
      ),
    );

    try {
      // 2. Llamada al UseCase
      print('[DEBUG-BLOC] Paso 2: Ejecutando createSessionUc...');
      final result = await createSessionUc.call(event.kahootId);

      print(
        '[DEBUG-BLOC] Paso 3: ¿Resultado exitoso?: ${result.isSuccessful()}',
      );

      if (result.isSuccessful()) {
        final session = result.getValue();
        final String sessionPin = session.sessionPin
            .toString(); // Aseguramos que sea String

        print('[DEBUG-BLOC] Paso 4: Sesión creada. PIN: $sessionPin');

        // 3. Emitimos éxito y pasamos a fase LOBBY
        emit(
          state.copyWith(
            status: LiveGameStatus.lobby,
            pin: sessionPin,
            session: session,
            nickname: 'Pepito', // Placeholder según tu lógica
          ),
        );

        // 4. Configuración del Stream de estados del juego
        print('[DEBUG-BLOC] Paso 5: Suscribiendo al stream de estados...');
        _gameStateSubscription?.cancel();
        _gameStateSubscription = repository.gameStateStream.listen(
          (data) {
            print(
              '[DEBUG-BLOC] Stream: Nuevo estado recibido -> ${data.phase}',
            );
            add(OnGameStateReceived(data));
          },
          onError: (err) {
            print('[DEBUG-BLOC] ERROR en Stream: $err');
          },
        );

        // 5. Conexión al Socket (Handshake)
        print('[DEBUG-BLOC] Paso 6: Conectando al socket...');
        connectToSocketUc.call(
          pin: sessionPin,
          role: 'HOST',
          nickname: 'Pepito',
          // HARDCODEADO según tu código
          jwt:
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjdhYmM2ZmVkLTY2NWUtNDYzZC1iNTRkLThkNzhjMTM5N2U2ZiIsImVtYWlsIjoibmNhcmxvc0BleGFtcGxlLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY3OTU4OTIxLCJleHAiOjE3Njc5NjYxMjF9.hcWKnnA9pIqHUGzIP-7-He0ydO2ZpYzFDdRxp3AAv30",
        );

        // 6. Sincronización final
        await Future.delayed(const Duration(milliseconds: 500));
        print('[DEBUG-BLOC] Paso 7: Enviando client_ready');
        repository.sendClientReady();
      } else {
        // Caso: El backend respondió pero con un error lógico
        print('[DEBUG-BLOC] ERROR: El UseCase devolvió isSuccessful = false');
        emit(
          state.copyWith(
            status: LiveGameStatus.error,
            errorMessage:
                "El servidor no pudo crear la sesión. Revisa el Kahoot ID.",
          ),
        );
      }
    } catch (e, stacktrace) {
      // Caso: Error de red, error de parseo (nulos) o caída del servidor
      print('[DEBUG-BLOC] EXCEPCIÓN CRÍTICA: $e');
      print('[DEBUG-BLOC] STACKTRACE: $stacktrace');

      emit(
        state.copyWith(
          status: LiveGameStatus.error,
          errorMessage:
              "Error de conexión: No se pudo contactar con el servidor.",
        ),
      );
    }
  }

  void _onJoinLobby(JoinLobby event, Emitter<LiveGameBlocState> emit) {
    print(
      '[BLOC] Guardando nickname y enviando player_join: ${event.nickname}',
    );

    // Guardar el nickname en el estado local antes de enviarlo
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
    print('[BLOC] Actualizando UI a fase: ${gameData.phase}');

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
    print('[BLOC] Cerrando BLoC y liberando recursos');
    _gameStateSubscription?.cancel();
    repository.disconnect();
    return super.close();
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<LiveGameBlocState> emit,
  ) async {
    // Log para ver qué recibe el Bloc
    print('[BLOC RECEIVING]: ${event.answerIds}');

    emit(state.copyWith(status: LiveGameStatus.waitingResults));

    // Llamada al repositorio
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
