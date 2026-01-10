import '../../common/core/result.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/repositories/group_repository.dart';

class GetGroupMembers {
  final GroupRepository repository;

  GetGroupMembers(this.repository);

  Future<Result<List<GroupMember>>> call(String userId, String groupId) {
    return repository.getGroupMembers(userId, groupId);
  }
}
