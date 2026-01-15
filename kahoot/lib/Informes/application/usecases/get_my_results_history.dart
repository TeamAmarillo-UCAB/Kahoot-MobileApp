
import '../../../core/result.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/entities/result_summary.dart';

class GetMyResultsHistory {
  final ReportsRepository repository;

  GetMyResultsHistory(this.repository);

  Future<Result<PaginatedResult>> call({int page = 1, int limit = 20}) async {
    return await repository.getMyResultsHistory(page: page, limit: limit);
  }
}