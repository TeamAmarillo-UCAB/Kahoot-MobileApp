// lib/Motor_Juego_Vivo/application/usecases/host_next_phase_usecase.dart

import '../../domain/repositories/game_repository.dart';

class HostNextPhaseUsecase {
  final GameRepository repository;

  HostNextPhaseUsecase(this.repository);

  Future<void> call() {
    return repository.hostNextPhase();
  }
}
