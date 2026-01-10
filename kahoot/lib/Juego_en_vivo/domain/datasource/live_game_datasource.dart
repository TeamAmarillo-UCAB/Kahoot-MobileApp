import '../entities/live_session.dart';

abstract class LiveGameDatasource {
  // HTTP
  Future<LiveSession> createSession(String kahootId);
  Future<Map<String, dynamic>> getPinByQR(String qrToken);

  // Socket
  void connect({
    required String pin,
    required String role,
    required String nickname,
    required String jwt,
  });
  void disconnect();
  void emit(String eventName, Map<String, dynamic> data);

  // Stream de eventos crudos (Event Name + Data Map)
  Stream<Map<String, dynamic>> get socketEvents;
}
