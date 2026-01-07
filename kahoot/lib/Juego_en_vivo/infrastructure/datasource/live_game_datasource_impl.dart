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

  //SOLICITUDES HTTP

  @override
  Future<LiveSession> createSession(String kahootId) async {
    // El Anfitrión crea una nueva sala a partir de un Kahoot existente.
    final response = await dio.post(
      '/multiplayer-sessions',
      data: {'kahootId': kahootId},
    );
    return LiveSession.fromJson(
      response.data,
    ); // Retorna sessionPin, qrToken y metadata.
  }

  @override
  Future<Map<String, dynamic>> getPinByQR(String qrToken) async {
    // Obtiene el sessionPin de una partida activa mediante el token del QR.
    final response = await dio.get('/multiplayer-sessions/qr-token/$qrToken');
    return response.data;
  }

  //GESTIÓN DE WEBSOCKETS

  @override
  void connect({
    required String pin,
    required String role,
    required String nickname,
    required String jwt,
  }) {
    // Handshake inicial con los parámetros requeridos en headers/query.
    _socket = io.io(
      'wss://quizzy-backend-0wh2.onrender.com/multiplayer-sessions',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({
            'pin': pin,
            'role': role.toUpperCase(), // 'HOST' o 'PLAYER'.
            'jwt': jwt,
          })
          .enableAutoConnect()
          .build(),
    );

    // Lista exhaustiva de eventos del servidor
    final serverEvents = [
      'HOST_CONNECTED_SUCCESS',
      'HOST_LOBBY_UPDATE',
      'PLAYER_CONNECTED_TO_SESSION',
      'player_left_session',
      'question_started',
      'player_answer_confirmation',
      'host_answer_update',
      'HOST_RESULTS',
      'PLAYER_RESULTS',
      'HOST_GAME_END',
      'PLAYER_GAME_END',
      'session_closed',
      'host_left_session',
      'host_returned_to_session',
      'SYNC_ERROR',
      'connection_error',
      'game_error',
    ];

    for (var event in serverEvents) {
      _socket!.on(event, (data) {
        _socketEventController.add({'event': event, 'data': data});
      });
    }
  }

  @override
  void emit(String eventName, Map<String, dynamic> data) {
    _socket?.emit(eventName, data);
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
