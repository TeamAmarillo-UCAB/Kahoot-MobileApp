import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io_socket;

import '../../domain/datasource/game_socket_datasource.dart';
import '../mappers/game_state_mapper.dart';
import '../../domain/entities/game_state.dart';

class GameSocketDatasourceImpl implements GameSocketDatasource {
  io_socket.Socket? _socket;
  final _controller = StreamController<GameStateEntity>.broadcast();

  /// Estado interno actual (para ir acumulando cambios)
  GameStateEntity _currentState = GameStateEntity.initial();

  @override
  Future<void> connect({
    required String pin,
    required String role,
    required String playerId,
    required String username,
    required String nickname,
  }) async {
    // ⚠️ IMPORTANTE: Cambiar por tu URL real cuando tengas backend
    final url = "http://localhost:3000/multiplayer-sessions";

    _socket = io_socket.io(
      url,
      io_socket.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    // Cuando el socket se conecta, mandamos el primer join
    _socket!.onConnect((_) {
      _socket!.emit("join", {
        "pin": pin,
        "role": role,
        "playerId": playerId,
        "username": username,
        "nickname": nickname,
      });
    });

    // Escuchar TODOS los eventos que lleguen del WS
    _socket!.onAny((event, data) {
      try {
        final mapped = GameStateMapper.mapEvent(
          oldState: _currentState,
          event: event,
          data: _castToStringMap(data),
        );

        _currentState = mapped;
        _controller.add(mapped);
      } catch (_) {
        // Ignorar eventos desconocidos
      }
    });
  }

  @override
  void emit(String event, payload) {
    _socket?.emit(event, payload);
  }

  @override
  Stream<GameStateEntity> listen() => _controller.stream;

  @override
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _controller.close();
  }

  // ───────────────────────────────────────────────
  // CONVERSIÓN SEGURA DE Map<dynamic, dynamic> → Map<String, dynamic>
  // ───────────────────────────────────────────────
  Map<String, dynamic> _castToStringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return {};
  }
}
