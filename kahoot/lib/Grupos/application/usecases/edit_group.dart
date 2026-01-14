import '../../common/core/result.dart';
import '../../domain/entities/group_detail.dart';
import '../../domain/repositories/group_repository.dart';

class EditGroup {
  final GroupRepository repository;

  EditGroup(this.repository);

  Future<Result<GroupDetail>> call(
    String userId,
    String groupId,
    String name,
    String description,
  ) {
    return repository.editGroup(userId, groupId, name, description);
  }
}
