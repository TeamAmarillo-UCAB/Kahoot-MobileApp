import '../../domain/entities/live_game_state.dart';
import '../../domain/entities/live_session.dart';

enum LiveGameStatus {
  initial,
  loading,
  lobby,
  question,
  results,
  podium,
  error,
}

class LiveGameBlocState {
  final LiveGameStatus status;
  final String? pin;
  final String? role; // 'HOST' | 'PLAYER'
  final LiveSession? session;
  final LiveGameState? gameData; // Entidad de dominio con la info del socket
  final String? errorMessage;

  LiveGameBlocState({
    this.status = LiveGameStatus.initial,
    this.pin,
    this.role,
    this.session,
    this.gameData,
    this.errorMessage,
  });

  LiveGameBlocState copyWith({
    LiveGameStatus? status,
    String? pin,
    String? role,
    LiveSession? session,
    LiveGameState? gameData,
    String? errorMessage,
  }) {
    return LiveGameBlocState(
      status: status ?? this.status,
      pin: pin ?? this.pin,
      role: role ?? this.role,
      session: session ?? this.session,
      gameData: gameData ?? this.gameData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
