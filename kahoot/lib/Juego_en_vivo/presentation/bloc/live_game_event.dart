import '../../domain/entities/live_game_state.dart';

abstract class LiveGameEvent {}

class InitHostSession extends LiveGameEvent {
  final String kahootId;
  InitHostSession(this.kahootId);
}

class InitPlayerSession extends LiveGameEvent {
  final String pin;
  InitPlayerSession(this.pin);
}

class ScanQrCode extends LiveGameEvent {
  final String qrToken;
  ScanQrCode(this.qrToken);
}

class JoinLobby extends LiveGameEvent {
  final String nickname;
  JoinLobby(this.nickname);
}

class StartGame extends LiveGameEvent {}

class NextPhase extends LiveGameEvent {}

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

class OnGameStateReceived extends LiveGameEvent {
  final LiveGameState gameState;
  OnGameStateReceived(this.gameState);
}
