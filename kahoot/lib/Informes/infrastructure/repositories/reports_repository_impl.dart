import '../../../core/result.dart';
import '../../domain/datasource/reports_datasource.dart';
import '../../domain/entities/player_result_detail.dart';
import '../../domain/entities/result_summary.dart';
import '../../domain/entities/session_report.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsDatasource datasource;

  ReportsRepositoryImpl({required this.datasource});

  @override
  Future<Result<PaginatedResult>> getMyResultsHistory({int page = 1, int limit = 20}) async {
    try {
      final data = await datasource.getMyResultsHistory(page: page, limit: limit);
      return Result.success(data);
    } catch (e) {
      return Result.makeError(Exception('Error al obtener historial: $e'));
    }
  }

  @override
  Future<Result<SessionReport>> getSessionReport(String sessionId) async {
    try {
      final data = await datasource.getSessionReport(sessionId);
      return Result.success(data);
    } catch (e) {
      return Result.makeError(Exception('Error al obtener informe de sesión: $e'));
    }
  }

  @override
  Future<Result<PlayerResultDetail>> getMultiplayerResult(String sessionId) async {
    try {
      final data = await datasource.getMultiplayerResult(sessionId);
      return Result.success(data);
    } catch (e) {
      return Result.makeError(Exception('Error al obtener resultados multijugador: $e'));
    }
  }

  @override
  Future<Result<PlayerResultDetail>> getSingleplayerResult(String attemptId) async {
    try {
      final data = await datasource.getSingleplayerResult(attemptId);
      return Result.success(data);
    } catch (e) {
      return Result.makeError(Exception('Error al obtener resultados singleplayer: $e'));
    }
  }
}