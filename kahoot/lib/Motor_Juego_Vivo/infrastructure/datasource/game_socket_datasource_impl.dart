// lib/Motor_Juego_Vivo/infrastructure/datasource/game_socket_datasource_impl.dart

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io_socket;

import '../../domain/datasource/game_socket_datasource.dart';

class GameSocketDatasourceImpl implements GameSocketDatasource {
  io_socket.Socket? _socket;

  @override
  Future<void> connect({
    required String pin,
    required String role,
    required String playerId,
    required String username,
    required String nickname,
  }) async {
    // TODO: Reemplazar con tu URL real
    throw UnimplementedError();
  }

  @override
  void emit(String event, payload) {
    _socket?.emit(event, payload);
  }

  @override
  Stream<dynamic> listen() {
    final controller = StreamController<dynamic>.broadcast();

    _socket?.onAny((event, data) {
      controller.add({"event": event, "data": data});
    });

    return controller.stream;
  }

  @override
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
