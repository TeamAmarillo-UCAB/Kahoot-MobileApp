abstract class GameSocketDatasource {
  Future<void> connect({
    required String pin,
    required String role,
    required String playerId,
    required String username,
    required String nickname,
  });

  void emit(String event, dynamic payload);

  Stream<dynamic> listen();

  void disconnect();
}
