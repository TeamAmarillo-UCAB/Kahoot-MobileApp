import '../../common/core/result.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';

class GetUserGroups {
  final GroupRepository repository;

  GetUserGroups(this.repository);

  Future<Result<List<Group>>> call(String userId) {
    return repository.getMyGroups(userId);
  }
}
