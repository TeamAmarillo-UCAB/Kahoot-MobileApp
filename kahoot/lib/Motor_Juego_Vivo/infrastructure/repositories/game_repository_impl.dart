import '../../domain/repositories/game_repository.dart';
import '../datasource/game_api_datasource.dart';
import '../datasource/game_socket_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  final GameApiDatasource api;
  final GameSocketDatasource socket;
  GameRepositoryImpl({required this.api, required this.socket});

  @override
  Future<Map<String, dynamic>> createSession(String kahootId) => api.createSession(kahootId);

  @override
  Future<Map<String, dynamic>> getSessionByQrToken(String qrToken) => api.getSessionByQrToken(qrToken);

  @override
  void connectToSession({required String sessionPin, required String nickname}) {
    socket.connect(baseUrl: 'https://tuservidor.com', sessionPin: sessionPin);
  }

  @override
  void disconnect() => socket.disconnect();

  @override
  void emitPlayerJoin(String sessionPin, String nickname) => socket.emit('player_join', {
    'sessionPin': sessionPin.toString(),
    'nickname': nickname,
  });

  @override
  void emitHostStartGame() => socket.emit('host_start_game', null);

  @override
  void emitPlayerSubmitAnswer({required String questionId, required answerId, required int timeElapsedMs}) =>
    socket.emit('player_submit_answer', {
      'questionId': questionId,
      'answerId': answerId,
      'timeElapsedMs': timeElapsedMs,
    });

  @override
  void emitHostNextPhase() => socket.emit('host_next_phase', null);

  @override
  void onGameState(void Function(Map<String, dynamic>) callback) =>
      socket.on('game_state_update', (payload) => callback(Map<String, dynamic>.from(payload)));

  @override
  void onQuestionStarted(void Function(Map<String, dynamic>) callback) =>
      socket.on('question_started', (payload) => callback(Map<String, dynamic>.from(payload)));

  @override
  void onQuestionResults(void Function(Map<String, dynamic>) callback) =>
      socket.on('question_results', (payload) => callback(Map<String, dynamic>.from(payload)));

  @override
  void onPlayerAnswerConfirmation(void Function(Map<String, dynamic>) callback) =>
      socket.on('player_answer_confirmation', (payload) => callback(Map<String, dynamic>.from(payload)));

  @override
  void onGameEnd(void Function(Map<String, dynamic>) callback) =>
      socket.on('game_end', (payload) => callback(Map<String, dynamic>.from(payload)));

  @override
  void onError(void Function(Map<String, dynamic>) callback) =>
      socket.on('game_error', (payload) => callback(Map<String, dynamic>.from(payload)));
}
