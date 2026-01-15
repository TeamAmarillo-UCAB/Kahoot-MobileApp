// lib/Informes_Estadisticas/domain/datasource/reports_datasource.dart

import '../entities/result_summary.dart';
import '../entities/session_report.dart';
import '../entities/player_result_detail.dart';

abstract class ReportsDatasource {
  /// Obtiene el historial de resultados del usuario paginado
  Future<PaginatedResult> getMyResultsHistory({int page = 1, int limit = 20});

  /// Obtiene el reporte completo de una sesión (Vista Anfitrión)
  /// Endpoint: /reports/sessions/:sessionId
  Future<SessionReport> getSessionReport(String sessionId);

  /// Obtiene el detalle de resultado de un jugador en Multiplayer
  /// Endpoint: /reports/multiplayer/:sessionId
  Future<PlayerResultDetail> getMultiplayerResult(String sessionId);

  /// Obtiene el detalle de resultado de un jugador en Singleplayer
  /// Endpoint: /reports/singleplayer/:attemptId
  Future<PlayerResultDetail> getSingleplayerResult(String attemptId);
}