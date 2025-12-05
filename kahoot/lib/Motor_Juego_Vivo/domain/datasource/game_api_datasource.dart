abstract class GameApiDatasource {
  Future<Map<String, dynamic>> createSession({required String kahootId});
  Future<Map<String, dynamic>> getSessionByQrToken({required String qrToken});
}
