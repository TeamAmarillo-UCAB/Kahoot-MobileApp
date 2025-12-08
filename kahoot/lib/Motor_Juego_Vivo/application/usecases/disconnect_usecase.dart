// lib/Motor_Juego_Vivo/application/usecases/disconnect_usecase.dart

import '../../domain/repositories/game_repository.dart';

class DisconnectUsecase {
  final GameRepository repository;

  DisconnectUsecase(this.repository);

  void call() {
    repository.disconnect();
  }
}
