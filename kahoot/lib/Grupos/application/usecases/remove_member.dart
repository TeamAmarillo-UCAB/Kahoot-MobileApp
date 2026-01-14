import '../../common/core/result.dart';
import '../../domain/repositories/group_repository.dart';

class RemoveMember {
  final GroupRepository repository;

  RemoveMember(this.repository);

  Future<Result<void>> call(String userId, String groupId, String memberId) {
    return repository.removeMember(userId, groupId, memberId);
  }
}
