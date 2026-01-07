import '../../domain/repositories/live_game_repository.dart';

class ConnectToSocket {
  final LiveGameRepository repository;

  ConnectToSocket(this.repository);

  void call({
    required String pin,
    required String role,
    required String nickname,
    required String jwt,
  }) {
    repository.connect(pin: pin, role: role, nickname: nickname, jwt: jwt);
  }
}
