import '../../domain/entities/live_game_state.dart';
import '../../domain/entities/live_session.dart';

enum LiveGameStatus {
  initial,
  loading,
  lobby,
  question,
  waitingResults,
  results,
  end, // Cambiado de 'podium' a 'end' según pág. 18 del PDF
  error,
}

class LiveGameBlocState {
  final LiveGameStatus status;
  final String? pin;
  final String? nickname;
  final String? role;
  final LiveSession? session;
  final LiveGameState? gameData;
  final String? errorMessage;

  LiveGameBlocState({
    this.status = LiveGameStatus.initial,
    this.pin,
    this.nickname,
    this.role,
    this.session,
    this.gameData,
    this.errorMessage,
  });

  LiveGameBlocState copyWith({
    LiveGameStatus? status,
    String? pin,
    String? nickname,
    String? role,
    LiveSession? session,
    LiveGameState? gameData,
    String? errorMessage,
  }) {
    return LiveGameBlocState(
      status: status ?? this.status,
      pin: pin ?? this.pin,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      session: session ?? this.session,
      gameData: gameData ?? this.gameData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
