// lib/Motor_Juego_Vivo/application/usecases/join_game_usecase.dart

import '../../domain/repositories/game_repository.dart';

class JoinGameParams {
  final String pin;
  final String role;        // "HOST" o "PLAYER"
  final String playerId;
  final String username;
  final String nickname;

  JoinGameParams({
    required this.pin,
    required this.role,
    required this.playerId,
    required this.username,
    required this.nickname,
  });
}

class JoinGameUsecase {
  final GameRepository repository;

  JoinGameUsecase(this.repository);

  Future<void> call(JoinGameParams params) {
    return repository.joinGame(
      pin: params.pin,
      role: params.role,
      playerId: params.playerId,
      username: params.username,
      nickname: params.nickname,
    );
  }
}
