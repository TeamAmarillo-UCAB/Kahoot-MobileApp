import '../../../core/result.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/entities/session_report.dart';

class GetSessionReport {
  final ReportsRepository repository;

  GetSessionReport(this.repository);

  Future<Result<SessionReport>> call(String sessionId) async {
    return await repository.getSessionReport(sessionId);
  }
}