import '../../domain/entities/game_state.dart';
import '../../domain/entities/player_info.dart';
import '../../domain/entities/question_slide.dart';
import '../../domain/entities/scoreboard_entry.dart';

class GameStateMapper {
  /// Mapea cualquier evento WebSocket hacia un nuevo GameStateEntity
  /// Añade prints para debug de mapeo (no invasivos).
  static GameStateEntity mapEvent({
    required GameStateEntity oldState,
    required String event,
    required Map<String, dynamic> data,
  }) {
    print('[GameStateMapper] event="$event" dataKeys=${data.keys.toList()}');

    switch (event) {
      case "game_state_update":
        // debug: si viene currentSlideData, listar options
        if (data["currentSlideData"] != null) {
          final cs = data["currentSlideData"] as Map<String, dynamic>;
          final optList = cs["options"] as List<dynamic>? ?? [];
          print('[GameStateMapper] game_state_update currentSlide options: ${optList.map((o) => (o is Map ? o["text"] : o)).toList()}');
        }

        return GameStateEntity(
          phase: GamePhaseX.fromString(data["state"] ?? "LOBBY"),
          players: PlayerInfo.fromJsonList(data["players"] ?? []),
          questionIndex: data["questionIndex"] ?? 0,
          quizTitle: data["quizTitle"],
          quizMediaUrl: data["quizMediaUrl"],
          currentSlide: data["currentSlideData"] == null
              ? null
              : QuestionSlide.fromJson(_ensureStringMap(data["currentSlideData"])),
          scoreboard: ScoreboardEntry.fromJsonList(data["scoreboard"] ?? []),
          correctAnswerId: data["correctAnswerId"],
          pointsEarned: data["pointsEarned"],
        );

      case "question_started":
        print('[GameStateMapper] mapping question_started');
        return oldState.copyWith(
          phase: GamePhase.question,
          questionIndex: data["questionIndex"] ?? oldState.questionIndex,
          currentSlide: data["currentSlideData"] == null
              ? null
              : QuestionSlide.fromJson(_ensureStringMap(data["currentSlideData"])),
          correctAnswerId: null,
          pointsEarned: null,
        );

      case "question_results":
        print('[GameStateMapper] mapping question_results; playerScoreboard keys: ${data["playerScoreboard"]?.length ?? 0}');
        return oldState.copyWith(
          phase: GamePhaseX.fromString(data["state"] ?? "RESULTS"),
          scoreboard:
              ScoreboardEntry.fromJsonList(data["playerScoreboard"] ?? []),
          correctAnswerId: data["correctAnswerId"],
          pointsEarned: data["pointsEarned"],
        );

      case "game_end":
        print('[GameStateMapper] mapping game_end');
        return oldState.copyWith(
          phase: GamePhaseX.fromString(data["state"] ?? "END"),
          scoreboard:
              ScoreboardEntry.fromJsonList(data["finalScoreboard"] ?? []),
          correctAnswerId: null,
          pointsEarned: null,
        );

      default:
        print('[GameStateMapper] event not recognized: "$event"');
        return oldState;
    }
  }

  // Convierte Map<dynamic,dynamic> -> Map<String,dynamic> (seguro)
  static Map<String, dynamic> _ensureStringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }
}
