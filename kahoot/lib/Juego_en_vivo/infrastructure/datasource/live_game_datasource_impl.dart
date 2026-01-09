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
    print('entró al datasource');
    final response = await dio.post(
      '/multiplayer-sessions',
      data: {'kahootId': kahootId},
    );
    print('imprimiendo datos');
    print(response.data);
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
    print('[DATASOURCE] Conectando a socket...');

    _socket = io.io(
      'wss://quizzy-backend-0wh2.onrender.com/multiplayer-sessions',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'pin': pin, 'role': role.toUpperCase(), 'jwt': jwt})
          .setQuery({'pin': pin, 'role': role.toUpperCase(), 'jwt': jwt})
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('[DATASOURCE] Socket Conectado');
      _socket!.emit('client_ready', {});
    });

    _socket!.onConnectError(
      (data) => print('[DATASOURCE] Error de Conexión: $data'),
    );
    _socket!.onDisconnect((data) => print('🔌 [DATASOURCE] Desconectado'));

    final serverEvents = [
      'player_connected_to_session',
      'question_started',
      'player_results',
      'player_answer_confirmation',
      'host_left_session',
      'session_closed',
      'game_error',
      'sync_error',
      'host_lobby_update',
      'host_results',
      'player_game_end',
    ];

    for (var event in serverEvents) {
      _socket!.on(event, (data) {
        print('[DATASOURCE] Evento Recibido: $event');

        // LOG CRÍTICO PARA DEBUG: Ver qué llega del servidor
        if (event == 'player_results' || event == 'HOST_RESULTS') {
          print('[DATASOURCE DATA RAW]: $data');
        }

        _socketEventController.add({'event': event, 'data': data});
      });
    }

    _socket!.onAny((event, data) {
      if (!serverEvents.contains(event)) {
        print('[DATASOURCE] Evento No Mapeado: $event -> $data');
      }
    });
  }

  @override
  void emit(String eventName, Map<String, dynamic> data) {
    if (_socket?.connected ?? false) {
      print('[DATASOURCE] Emitiendo: $eventName');
      _socket!.emit(eventName, data);
    } else {
      print('[DATASOURCE] Socket no conectado para emitir $eventName');
    }
  }

  @override
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  @override
  Stream<Map<String, dynamic>> get socketEvents =>
      _socketEventController.stream;
}
