// lib/domain/entities/live_game_state.dart
import 'live_slide.dart';

class LiveGameState {
  final String phase;
  final LiveSlide? currentSlide;
  final List<dynamic>? players;
  final List<dynamic>? leaderboard;
  final bool? lastWasCorrect;
  final int? lastPointsEarned;
  final int? totalScore;
  final int? rank;
  final List<String>? correctAnswerIds;
  final String? feedbackMessage; // <--- Agregado
  final dynamic podiumData;

  LiveGameState({
    required this.phase,
    this.currentSlide,
    this.players,
    this.leaderboard,
    this.lastWasCorrect,
    this.lastPointsEarned,
    this.totalScore,
    this.rank,
    this.correctAnswerIds,
    this.feedbackMessage,
    this.podiumData,
  });

  factory LiveGameState.fromJson(String phase, Map<String, dynamic> json) {
    return LiveGameState(
      phase: phase,
      currentSlide: json['currentSlideData'] != null
          ? LiveSlide.fromJson(json['currentSlideData'])
          : null,
      players: json['players'],
      leaderboard: json['leaderboard'],
      lastWasCorrect: json['isCorrect'],
      lastPointsEarned: json['pointsEarned'],
      totalScore: json['totalScore'] ?? json['score'],
      rank: json['rank'],
      feedbackMessage: json['message'], // <--- Mapeo de la llave del servidor
      correctAnswerIds: (json['correctAnswerIds'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      podiumData: json['finalPodium'] ?? json['winner'],
    );
  }
}
