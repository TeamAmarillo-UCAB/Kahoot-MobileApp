import '../../domain/datasource/game_api_datasource.dart';

class FakeApiDatasource implements GameApiDatasource {
  @override
  Future<Map<String, dynamic>> createSession({required String kahootId}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      "sessionPin": 123456,
      "sessionId": "fake-session-id-001",
      "hostSocketUrl": "/multiplayer-sessions"
    };
  }

  @override
  Future<Map<String, dynamic>> getSessionByQrToken({required String qrToken}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return {
      "gamePin": 123456,
      "sessionId": "fake-session-id-001",
      "status": "LOBBY"
    };
  }
}
