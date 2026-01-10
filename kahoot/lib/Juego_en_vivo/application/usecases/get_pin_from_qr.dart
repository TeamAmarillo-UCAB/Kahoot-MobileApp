import '../../domain/repositories/live_game_repository.dart';
import '../../common/core/result.dart';

class GetPinFromQr {
  final LiveGameRepository repository;

  GetPinFromQr(this.repository);

  Future<Result<Map<String, dynamic>>> call(String qrToken) async {
    return await repository.getPinByQR(qrToken);
  }
}
