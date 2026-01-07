import '../../domain/datasource/live_game_datasource.dart';
import '../../domain/repositories/live_game_repository.dart';
import '../../domain/entities/live_session.dart';
import '../../domain/entities/live_game_state.dart';
import '../../common/core/result.dart';

class LiveGameRepositoryImpl implements LiveGameRepository {
  final LiveGameDatasource datasource;

  LiveGameRepositoryImpl({required this.datasource});

  @override
  Future<Result<LiveSession>> createSession(String kahootId) async {
    try {
      final session = await datasource.createSession(kahootId);
      return Result.success(session);
    } catch (e) {
      return Result.makeError(Exception('Fallo al crear sesión [cite: 3]'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPinByQR(String qrToken) async {
    try {
      final data = await datasource.getPinByQR(qrToken);
      return Result.success(data);
    } catch (e) {
      return Result.makeError(Exception('QR no válido [cite: 5]'));
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
  void sendClientReady() {
    // Se emite tras suscribir los listeners para disparar la sincronización[cite: 10].
    datasource.emit('client_ready', {});
  }

  @override
  void joinPlayer(String nickname) {
    // Une al jugador al dominio con un nickname de 6-20 caracteres[cite: 13].
    datasource.emit('player_join', {'nickname': nickname});
  }

  @override
  void hostStartGame() => datasource.emit('host_start_game', {}); // [cite: 14]

  @override
  void hostNextPhase() => datasource.emit('host_next_phase', {}); // [cite: 27]

  @override
  void submitAnswer({
    required String questionId,
    required List<String> answerIds,
    required int timeElapsedMs,
  }) {
    // Envía respuesta con IDs de opción y tiempo transcurrido[cite: 22].
    datasource.emit('player_submit_answer', {
      'questionId': questionId,
      'answerIds': answerIds,
      'timeElapsedMs': timeElapsedMs,
    });
  }

  @override
  Stream<LiveGameState> get gameStateStream {
    return datasource.socketEvents.map((payload) {
      final event = payload['event'];
      final data = payload['data'] as Map<String, dynamic>;

      // Mapeo dinámico de eventos de ráfaga a fases de la UI[cite: 70, 71, 72].
      String phase = 'UNKNOWN';
      if (event.contains('LOBBY') || event == 'player_connected_to_session')
        phase = 'LOBBY';
      if (event == 'question_started') phase = 'QUESTION';
      if (event.contains('RESULTS')) phase = 'RESULTS';
      if (event.contains('GAME_END')) phase = 'PODIUM';
      if (event == 'player_answer_confirmation') phase = 'WAITING_RESULTS';
      if (event == 'session_closed') phase = 'CLOSED';

      return LiveGameState.fromJson(phase, data);
    });
  }
}
