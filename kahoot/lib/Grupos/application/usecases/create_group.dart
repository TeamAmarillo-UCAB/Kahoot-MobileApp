import '../../common/core/result.dart';
import '../../domain/entities/group_detail.dart';
import '../../domain/repositories/group_repository.dart';

class CreateGroup {
  final GroupRepository repository;

  CreateGroup(this.repository);

  Future<Result<GroupDetail>> call(
    String userId,
    String name,
    String description,
  ) {
    return repository.createGroup(userId, name, description);
  }
}
