import '../../domain/repositories/game_repository.dart';

class ScanQrUsecase {
  final GameRepository repository;

  ScanQrUsecase(this.repository);

  Future<void> call(String qrToken) {
    return repository.scanQr(qrToken: qrToken);
  }
}
