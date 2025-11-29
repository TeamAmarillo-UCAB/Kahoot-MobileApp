import 'package:dio/dio.dart';

class GameApiDatasource {
  final Dio _dio;
  GameApiDatasource(this._dio);

  Future<Map<String, dynamic>> createSession(String kahootId) async {
    final resp = await _dio.post('/multiplayer-sessions', data: {'kahootId': kahootId});
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSessionByQrToken(String qrToken) async {
    final resp = await _dio.get('/multiplayer-sessions/qr-token/$qrToken');
    return resp.data as Map<String, dynamic>;
  }
}
