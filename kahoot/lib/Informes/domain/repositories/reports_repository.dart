import '../../../core/result.dart';
import '../entities/result_summary.dart';
import '../entities/session_report.dart';
import '../entities/player_result_detail.dart';

abstract class ReportsRepository {
  
  Future<Result<PaginatedResult>> getMyResultsHistory({int page = 1, int limit = 20});

  Future<Result<SessionReport>> getSessionReport(String sessionId);

  // Podemos unificar estos dos en uno solo si el Caso de Uso lo prefiere, 
  // pero mantenerlos separados da más control.
  Future<Result<PlayerResultDetail>> getMultiplayerResult(String sessionId);

  Future<Result<PlayerResultDetail>> getSingleplayerResult(String attemptId);
}