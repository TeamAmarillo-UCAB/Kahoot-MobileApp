import 'dart:async';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../domain/datasource/live_game_datasource.dart';
import '../../domain/entities/live_session.dart';

class LiveGameDatasourceImpl implements LiveGameDatasource {
  final Dio dio;
  io.Socket? _socket;
  final _socketEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  LiveGameDatasourceImpl({required this.dio});

  @override
  Future<LiveSession> createSession(String kahootId) async {
    final response = await dio.post(
      '/multiplayer-sessions',
      data: {'kahootId': kahootId},
    );
    return LiveSession.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> getPinByQR(String qrToken) async {
    final response = await dio.get('/multiplayer-sessions/qr-token/$qrToken');
    return response.data;
  }

  @override
  void connect({
    required String pin,
    required String role,
    required String nickname,
    required String jwt,
  }) {
    print('🔌 [DATASOURCE] Iniciando intento de conexión...');
    print('📋 Parámetros: PIN: $pin, ROLE: $role, JWT: $jwt');

    // Configuración espejo de Postman (Headers + Query)
    _socket = io.io(
      'wss://quizzy-backend-0wh2.onrender.com/multiplayer-sessions',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'pin': pin, 'role': role.toUpperCase(), 'jwt': jwt})
          .setQuery({'pin': pin, 'role': role.toUpperCase(), 'jwt': jwt})
          .enableAutoConnect()
          .build(),
    );

    // --- LOGS DE ESTADO DE RED ---
    _socket!.onConnect((_) {
      print('✅ [DATASOURCE] Webshocket Conectado');
      // Emitimos client_ready aquí mismo, justo cuando el túnel se abre
      _socket!.emit('client_ready', {});
      print(
        '📢 [DATASOURCE] client_ready enviado automáticamente tras conexión',
      );
    });

    _socket!.onConnectError((data) {
      print('❌ [DATASOURCE] Error de Conexión: $data');
    });

    _socket!.onDisconnect((data) {
      print('🔌 [DATASOURCE] Socket Desconectado: $data');
    });

    // Lista exhaustiva de eventos del servidor para loguear todo
    final serverEvents = [
      'HOST_CONNECTED_SUCCESS',
      'HOST_LOBBY_UPDATE',
      'player_connected_to_session',
      'player_left_session',
      'question_started',
      'player_answer_confirmation',
      'host_answer_update',
      'HOST_RESULTS',
      'PLAYER_RESULTS',
      'HOST_GAME_END',
      'PLAYER_GAME_END',
      'session_closed',
      'SYNC_ERROR',
      'connection_error',
      'game_error',
    ];

    for (var event in serverEvents) {
      _socket!.on(event, (data) {
        print('📩 [DATASOURCE] Evento Recibido: $event');
        print('📦 [DATASOURCE] Payload: $data');
        _socketEventController.add({'event': event, 'data': data});
      });
    }

    // Log para cualquier evento no registrado
    _socket!.onAny((event, data) {
      if (!serverEvents.contains(event)) {
        print('❓ [DATASOURCE] Evento No Mapeado: $event -> $data');
      }
    });
  }

  @override
  void emit(String eventName, Map<String, dynamic> data) {
    if (_socket?.connected ?? false) {
      print('📤 [DATASOURCE] Emitiendo: $eventName con $data');
      _socket!.emit(eventName, data);
    } else {
      print(
        '⚠️ [DATASOURCE] Intento de emitir $eventName fallido: Socket no conectado',
      );
    }
  }

  @override
  void disconnect() {
    print('🔌 [DATASOURCE] Cerrando conexión voluntariamente');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  @override
  Stream<Map<String, dynamic>> get socketEvents =>
      _socketEventController.stream;
}
