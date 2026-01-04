import '../../common/core/result.dart';
import '../../domain/repositories/group_repository.dart';

class DeleteGroup {
  final GroupRepository repository;

  DeleteGroup(this.repository);

  Future<Result<void>> call(String userId, String groupId) {
    return repository.deleteGroup(userId, groupId);
  }
}
