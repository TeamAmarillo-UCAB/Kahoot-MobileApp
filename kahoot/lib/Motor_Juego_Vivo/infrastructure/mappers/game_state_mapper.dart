// import '../../domain/entities/game_state.dart';

// class GameStateMapper {
//   static GameStateEntity fromWs(Map<String, dynamic> json) {
//     return GameStateEntity.fromJson(json);
//   }
// }

import '../../domain/entities/game_state.dart';
import '../../domain/entities/player_info.dart';
import '../../domain/entities/question_slide.dart';
import '../../domain/entities/scoreboard_entry.dart';

class GameStateMapper {
  /// Mapea cualquier evento WebSocket hacia un nuevo GameStateEntity
  static GameStateEntity mapEvent({
    required GameStateEntity oldState,
    required String event,
    required Map<String, dynamic> data,
  }) {
    switch (event) {
      case "game_state_update":
        return GameStateEntity(
          phase: GamePhaseX.fromString(data["state"] ?? "LOBBY"),
          players: PlayerInfo.fromJsonList(data["players"] ?? []),
          questionIndex: data["questionIndex"] ?? 0,
          quizTitle: data["quizTitle"],
          quizMediaUrl: data["quizMediaUrl"],
          currentSlide: data["currentSlideData"] == null
              ? null
              : QuestionSlide.fromJson(data["currentSlideData"]),
          scoreboard: ScoreboardEntry.fromJsonList(data["scoreboard"] ?? []),
          correctAnswerId: null,
          pointsEarned: null,
        );

      case "question_started":
        return oldState.copyWith(
          phase: GamePhase.question,
          questionIndex: data["questionIndex"] ?? oldState.questionIndex,
          currentSlide: data["currentSlideData"] == null
              ? null
              : QuestionSlide.fromJson(data["currentSlideData"]),
          correctAnswerId: null,
          pointsEarned: null,
        );

      case "question_results":
        return oldState.copyWith(
          phase: GamePhaseX.fromString(data["state"] ?? "RESULTS"),
          scoreboard:
              ScoreboardEntry.fromJsonList(data["playerScoreboard"] ?? []),
          correctAnswerId: data["correctAnswerId"],
          pointsEarned: data["pointsEarned"],
        );

      case "game_end":
        return oldState.copyWith(
          phase: GamePhaseX.fromString(data["state"] ?? "END"),
          scoreboard:
              ScoreboardEntry.fromJsonList(data["finalScoreboard"] ?? []),
          correctAnswerId: null,
          pointsEarned: null,
        );

      default:
        return oldState;
    }
  }
}

