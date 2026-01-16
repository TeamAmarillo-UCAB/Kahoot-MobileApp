// lib/Informes_Estadisticas/domain/entities/result_summary.dart

import 'game_type.dart';

class ResultSummary {
  final String kahootId;
  final String gameId; // Puede ser attemptId o sessionId dependiendo del tipo
  final GameType gameType;
  final String title;
  final DateTime completionDate;
  final int? finalScore;
  final int? rankingPosition;

  ResultSummary({
    required this.kahootId,
    required this.gameId,
    required this.gameType,
    required this.title,
    required this.completionDate,
    this.finalScore,
    this.rankingPosition,
  });

  factory ResultSummary.fromJson(Map<String, dynamic> json) {
    return ResultSummary(
      kahootId: json['kahootId'] ?? '',
      gameId: json['gameId'] ?? '',
      gameType: GameType.fromString(json['gameType'] ?? ''),
      title: json['title'] ?? 'Sin título',
      completionDate: DateTime.tryParse(json['completionDate'] ?? '') ?? DateTime.now(),
      finalScore: json['finalScore'], // Puede ser null
      rankingPosition: json['rankingPosition'], // Puede ser null
    );
  }
}

class PaginatedResult {
  final List<ResultSummary> results;
  final int totalItems;
  final int currentPage;
  final int totalPages;

  PaginatedResult({
    required this.results,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
  });

  factory PaginatedResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['results'] ?? [];
    final meta = json['meta'] ?? {};

    return PaginatedResult(
      results: list.map((e) => ResultSummary.fromJson(e)).toList(),
      totalItems: meta['totalItems'] ?? 0,
      currentPage: meta['currentPage'] ?? 1,
      totalPages: meta['totalPages'] ?? 1,
    );
  }
}