import '../../domain/datasource/live_game_datasource.dart';
import '../../domain/repositories/live_game_repository.dart';
import '../../domain/entities/live_session.dart';
import '../../domain/entities/live_game_state.dart';
import '../../common/core/result.dart';
import 'dart:convert';

class LiveGameRepositoryImpl implements LiveGameRepository {
  final LiveGameDatasource datasource;

  LiveGameRepositoryImpl({required this.datasource});

  @override
  Future<Result<LiveSession>> createSession(String kahootId) async {
    try {
      print("llegó al repo");
      final session = await datasource.createSession(kahootId);
      print("Éxito en repo");
      return Result.success(session);
    } catch (e) {
      return Result.makeError(Exception('Fallo al crear sesión'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPinByQR(String qrToken) async {
    try {
      final data = await datasource.getPinByQR(qrToken);
      return Result.success(data);
    } catch (e) {
      return Result.makeError(Exception('QR no válido'));
    }
  }

  @override
  void connect({
    required String pin,
    required String role,
    required String nickname,
    required String jwt,
  }) {
    datasource.connect(pin: pin, role: role, nickname: nickname, jwt: jwt);
  }

  @override
  void disconnect() => datasource.disconnect();

  @override
  void sendClientReady() => datasource.emit('client_ready', {});

  @override
  void joinPlayer(String nickname) {
    datasource.emit('player_join', {'nickname': nickname});
  }

  @override
  void hostStartGame() => datasource.emit('host_start_game', {});

  @override
  void hostNextPhase() => datasource.emit('host_next_phase', {});

  @override
  void submitAnswer({
    required String questionId,
    required List<String> answerIds,
    required int timeElapsedMs,
  }) {
    final List<dynamic> finalIds = answerIds.map((id) {
      return int.tryParse(id) ?? id;
    }).toList();

    final payload = {
      "questionId": questionId,
      "answerId": finalIds,
      "timeElapsedMs": timeElapsedMs,
    };

    print('[REPOSITORY] Enviando MULTIPLE: ${jsonEncode(payload)}');
    datasource.emit('player_submit_answer', payload);
  }

  @override
  Stream<LiveGameState> get gameStateStream {
    return datasource.socketEvents.map((payload) {
      final event = (payload['event'] as String).toLowerCase();
      final data = payload['data'] as Map<String, dynamic>? ?? {};

      final String serverState = (data['state'] ?? '').toString().toLowerCase();

      String phase = 'UNKNOWN';

      if (event == 'question_started' || serverState == 'question') {
        phase = 'QUESTION';
      } else if (event == 'player_connected_to_session' ||
          serverState == 'lobby') {
        phase = 'LOBBY';
      } else if (event == 'player_results' || serverState == 'results') {
        phase = 'RESULTS';
      } else if (event == 'player_answer_confirmation') {
        phase = 'WAITING_RESULTS';
      } else if (event == 'player_game_end' ||
          serverState == 'end' ||
          event == 'game_over') {
        phase = 'END';
      } else if (event == 'host_left_session' || event == 'session_closed') {
        phase = 'HOST_DISCONNECTED';
      }

      if (phase == 'UNKNOWN') {
        print('[REPOSITORY] Evento No Mapeado: $event -> $data');
      } else {
        print('[REPOSITORY] Evento Mapeado: $event -> Fase: $phase');
      }

      return LiveGameState.fromJson(phase, data);
    });
  }
}
