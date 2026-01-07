import '../../domain/entities/live_game_state.dart';

abstract class LiveGameEvent {}

// Evento para el Host: Crear sesión e iniciar conexión
class InitHostSession extends LiveGameEvent {
  final String kahootId;
  InitHostSession(this.kahootId);
}

// Evento para el Jugador: Unirse con PIN manual
class InitPlayerSession extends LiveGameEvent {
  final String pin;
  InitPlayerSession(this.pin);
}

// Evento para el Jugador: Unirse mediante QR
class ScanQrCode extends LiveGameEvent {
  final String qrToken;
  ScanQrCode(this.qrToken);
}

// Evento para enviar el nickname al Lobby (Jugador)
class JoinLobby extends LiveGameEvent {
  final String nickname;
  JoinLobby(this.nickname);
}

// Acciones de control (Sincronización y Navegación)
class StartGame extends LiveGameEvent {}

class NextPhase extends LiveGameEvent {}

// Envío de respuesta (Jugador)
class SubmitAnswer extends LiveGameEvent {
  final String questionId;
  final List<String> answerIds;
  final int timeElapsedMs;
  SubmitAnswer({
    required this.questionId,
    required this.answerIds,
    required this.timeElapsedMs,
  });
}

// EVENTO INTERNO: Para procesar las ráfagas del Stream del Socket
class OnGameStateReceived extends LiveGameEvent {
  final LiveGameState gameState;
  OnGameStateReceived(this.gameState);
}
