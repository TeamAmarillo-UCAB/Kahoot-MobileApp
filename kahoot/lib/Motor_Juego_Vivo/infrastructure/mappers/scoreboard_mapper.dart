import '../../domain/entities/scoreboard_entry.dart';

class ScoreboardMapper {
  
  /// Mapea un solo objeto scoreboard del WS → entidad
  static ScoreboardEntry fromWs(Map<String, dynamic> json) {
    return ScoreboardEntry.fromJson(json);
  }

  /// Mapea una lista completa de scoreboard del WS → lista de entidades
  static List<ScoreboardEntry> fromWsList(List list) {
    return ScoreboardEntry.fromJsonList(list);
  }
}
