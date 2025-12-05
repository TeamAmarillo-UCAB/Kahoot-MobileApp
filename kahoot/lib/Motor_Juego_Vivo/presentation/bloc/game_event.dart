import 'package:equatable/equatable.dart';
import '../../domain/entities/game_state.dart';

abstract class GameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ───────────────────────────────
// Conexión inicial
// ───────────────────────────────
class GameEventJoin extends GameEvent {
  final String pin;
  final String role; // "HOST" o "PLAYER"
  final String playerId;
  final String username;
  final String nickname;

  GameEventJoin({
    required this.pin,
    required this.role,
    required this.playerId,
    required this.username,
    required this.nickname,
  });
}

// ───────────────────────────────
// Host inicia juego
// ───────────────────────────────
class GameEventHostStartGame extends GameEvent {}

// ───────────────────────────────
// Host pasa a siguiente fase
// ───────────────────────────────
class GameEventHostNextPhase extends GameEvent {}

// ───────────────────────────────
// Jugador envía respuesta
// ───────────────────────────────
class GameEventSubmitAnswer extends GameEvent {
  final String questionId;
  final int answerId;
  final int timeElapsedMs;

  GameEventSubmitAnswer({
    required this.questionId,
    required this.answerId,
    required this.timeElapsedMs,
  });
}

// ───────────────────────────────
// El servidor envía actualización WS
// ───────────────────────────────
class GameEventServerUpdate extends GameEvent {
  final GameStateEntity newState;

  GameEventServerUpdate(this.newState);
}

// ───────────────────────────────
// Desconectar
// ───────────────────────────────
class GameEventDisconnect extends GameEvent {}
