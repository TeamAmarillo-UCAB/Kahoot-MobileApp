import 'package:socket_io_client/socket_io_client.dart' as io_socket;

class GameSocketDatasource {
  io_socket.Socket? _socket;

  void connect({required String baseUrl, required String sessionPin}) {
    final uri = '$baseUrl/multiplayer-sessions';
    _socket = io_socket.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'sessionPin': sessionPin},
    });
    _socket!.connect();
  }

  void disconnect() => _socket?.disconnect();

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, void Function(dynamic) handler) {
    _socket?.on(event, (payload) => handler(payload));
  }

  void off(String event) {
    _socket?.off(event);
  }

  bool get connected => _socket?.connected ?? false;
}
