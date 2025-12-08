// lib/Motor_Juego_Vivo/application/usecases/host_start_game_usecase.dart

import '../../domain/repositories/game_repository.dart';

class HostStartGameUsecase {
  final GameRepository repository;

  HostStartGameUsecase(this.repository);

  Future<void> call() {
    return repository.hostStartGame();
  }
}
